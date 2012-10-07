# Take the Freebase data stored in Redis and load it into CouchDB as structured
# documents

require 'colors'
async = require 'async'
redis_client = require '../redis_connection'
couchdb = require '../cradle_connection' # couchdb client

load_location = require './load_location'

# Splits a redis key by ':' separator and returns the second half
extract_id_from = (key) -> key.split(':')[1]

load_cities_and_towns = (callback) ->
	console.log 'finding citytowns...'

	redis_client.keys 'citytown:*', (error, citytown_keys) ->
		if error?
			console.error "error loading citytowns: #{error}".red
		else
			console.log 'Got citytowns'
			callback(citytown_keys)

load_citytown = (citytown_key) ->
	(callback) ->
		load_location(citytown_key, callback)

save_queue = []

save_citytown = (location, callback) ->
	if save_queue.length >= 200
		couchdb.save save_queue, callback
		save_queue = []
	else
		save_queue.push location
		callback(null)

load_and_save_citytown = (citytown_key, callback) ->
	async.waterfall [ load_citytown(citytown_key), save_citytown ], callback

queue = async.queue load_and_save_citytown, 1

queue.load_and_save = (citytown_key) ->
	queue.push citytown_key, (error) ->
		if error?
			console.error "Error while saving citytown #{citytown_key}: #{error}".red

progress =
	track: ->
		# The total number of items to process
		@total = queue.length()
		# The number of items in the queue the last time we checked
		@last = queue.length()

		interval = 5000

		@progress_tracker = setInterval =>
			diff = @last - queue.length()
			speed = diff * 1000 / interval
			estimated_time_to_complete = queue.length() / (60 * speed)
			progress.last = queue.length()
			percent_complete = ((@total - queue.length()) / @total) * 100
			console.log "#{queue.length()} remaining - #{Math.round percent_complete}% complete"
			console.log "Estimated time to completion: #{Math.round estimated_time_to_complete} minutes @ #{speed}/second"
		, interval

	finished: ->
		clearInterval @progress_tracker

populate_couchdb = (concurrency, callback) ->
	queue.concurrency = concurrency
	queue.drain = callback

	load_cities_and_towns (citytown_keys) ->
		for citytown_key in citytown_keys
			queue.load_and_save citytown_key

		progress.track()

if !module.parent?
	populate_couchdb 2, ->
		console.log 'Finished populating CouchDB!'.green
		redis_client.quit()
		progress.finished()

module.exports = populate_couchdb
