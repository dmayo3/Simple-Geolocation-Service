redis = require 'redis'
cradle = require 'cradle' # couchdb client
async = require 'async'

cradle.setup
	host: 'http://localhost/'
	port: 5984
	cache: false # Do not use client write-through cache
	raw: false

redis_client = redis.createClient(6379)

cradle_client = new cradle.Connection()
couchdb = cradle_client.database('geolocation')

# Splits a redis key by ':' separator and returns the second half
extract_id_from = (key) -> key.split(':')[1]

load_cities_and_towns = (callback) ->
	console.log 'finding citytowns...'

	redis_client.keys 'citytown:*', (error, citytown_keys) ->
		if error?
			console.log "error loading citytowns: #{error}"
		else
			console.log 'Got citytowns'
			callback(citytown_keys)

throttle_load = (keys, callback) ->
	callback(keys)

	console.log 'Begin throttling!'

	# When redis_client is ready for more operations
	redis_client.on 'drain', ->
		# Progress indicator
		callback(keys)

batch_load = (callback) ->
	(keys) ->
		# Batch up operations
		for i in [1..100] when keys.length > 0
			key = keys.pop()
			id = extract_id_from(key)
			callback(id)
		
		if keys.length == 0
			# Done!
			console.log 'Finished loading!'
			redis_client.removeAllListeners 'drain'
			# Need to do this to avoid 'Redis connection gone from close event' error. Isn't there a better way? 
			setTimeout ->
				console.log 'Quiting!'
				redis_client.quit()
			, 0

load_citytown = (id, callback) ->
	(callback) ->
		redis_client.hgetall "location:#{id}", callback

load_geocode = (location, callback) ->
	callback(null, 'done')

load_cities_and_towns (citytown_keys) ->
	throttle_load citytown_keys, batch_load (citytown_id) ->
		async.waterfall [ load_citytown(citytown_id), load_geocode ], (error) ->
			if error?
				console.log "Error while loading citytown #{citytown_id}: #{error}"
