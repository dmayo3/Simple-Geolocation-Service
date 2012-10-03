# Take the Freebase data stored in Redis and load it into CouchDB as structured
# documents

async = require 'async'
redis_client = require 'redis_connection'
couchdb = require 'cradle_connection' # couchdb client

load_location = require './load_location'

# Splits a redis key by ':' separator and returns the second half
extract_id_from = (key) -> key.split(':')[1]

load_cities_and_towns = (callback) ->
	console.log 'finding citytowns...'

	redis_client.keys 'citytown:*', (error, citytown_keys) ->
		if error?
			console.error "error loading citytowns: #{error}"
		else
			console.log 'Got citytowns'
			callback(citytown_keys)

load_citytown = (citytown_key) ->
	(callback) ->
		load_location(citytown_key, callback)

save_citytown = (location, callback) ->
	couchdb.save location, callback

load_and_save_citytown = (citytown_key, callback) ->
	async.waterfall [ load_citytown(citytown_key), save_citytown ], callback

queue = async.queue load_and_save_citytown, 1

queue.load_and_save = (citytown_key) ->
	queue.push citytown_key, (error) ->
		if error?
			console.error "Error while saving citytown #{citytown_key}: #{error}"

track_progress = ->
	progress = 
		total: queue.length()
		last: queue.length()

	interval = 2000

	setInterval ->
		diff = progress.last - queue.length()
		speed = diff * 1000 / interval
		estimated_time_to_complete = queue.length() / (60 * speed)
		progress.last = queue.length()
		percent_complete = (progress.total - queue.length()) / progress.total
		console.log "#{queue.length()} remaining - #{Math.round percent_complete}% complete"
		console.log "Estimated time to completion: #{Math.round estimated_time_to_complete} minutes @ #{speed}/second"
	, interval

populate_couchdb = (concurrency, callback) ->
	queue.concurrency = concurrency
	queue.drain = callback

	load_cities_and_towns (citytown_keys) ->
		for citytown_key in citytown_keys
			queue.load_and_save citytown_key

		track_progress()

if !module.parent?
	populate_couchdb 6, ->
		console.log 'Finished populating CouchDB!'
		redis_client.quit()

module.exports = populate_couchdb
