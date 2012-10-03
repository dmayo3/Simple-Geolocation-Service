async = require 'async'
redis_client = require 'redis_connection'

load_citytown_id = (citytown_key) ->
	(callback) ->
		redis_client.get citytown_key, callback

load_citytown = (id, callback) ->
	redis_client.hgetall "location:#{id}", (error, location) ->
		if error?
			callback(error, null)
		else if not location?
			callback("No location found with id: #{id}", null)
		else
			location._id = id
			callback(null, location)

load_geocode = (location, callback) ->
	if location.geolocation?
		id = location.geolocation
		redis_client.hgetall "geocode:#{id}", (error, geocode) ->
			if error?
				callback(error, null)
			else if geocode?
				location.geolocation = geocode
				callback(null, location)
			else
				delete location.geolocation
				callback(null, location)
			
	else
		callback(null, location)

load_airports = (location, callback) ->
	redis_client.smembers "nearby_airports:#{location._id}", (error, airports) ->
		if error?
			callback(error, null)
		else if not airports?
			callback(null, location)
		else
			location.nearby_airports = airports
			callback(null, location)

load_location = (citytown_key, callback) ->
	async.waterfall [ load_citytown_id(citytown_key), load_citytown, load_geocode, load_airports ], callback

# TODO load contained-by data

module.exports = load_location
