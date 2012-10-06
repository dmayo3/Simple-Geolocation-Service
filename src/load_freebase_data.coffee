# Load Freebase TSV data and store the bits we want in Redis

redis = require 'redis'
csv = require 'csv'
async = require 'async'

String.prototype.toTitleCase = require('./common').toTitleCase

redis_client = require './redis_connection'

redis_client.on 'error', (error) ->
	console.log "Redis client error: #{error}"

location_tsv_dump = __dirname + '/../location.tsv'
geocode_tsv_dump = __dirname + '/../geocode.tsv'
citytown_tsv_dump = __dirname + '/../citytown.tsv'

parse_tsv = (file, termination_callback, data_callback) ->
	csv().
		fromPath(file,
			delimiter: '\t'
			quote: ''
			columns: true
	).on('data', (data, index) ->
        # Progress tick
		console.log '.' if index % 50000 == 0
		data_callback(data, index)
	).on('end', (count) ->
		console.log "Parsed: #{count} lines from #{file}"
		termination_callback()
	).on('error', (error) ->
		console.log error.message
	)

parse_location_data = (termination_callback) ->
	parse_tsv location_tsv_dump, termination_callback, (data, index) ->
		if data.name?
			location = { name: data.name }
			location.geolocation = data.geolocation if data.geolocation?
            # TODO split containedBy into array and store in a set
			location.containedby = data.containedby if data.containedby?

			redis_client.hmset "location:#{data.id}", location

			if data.nearby_airports?
				nearby_airports = data.nearby_airports.split ','
				nearby_airports.forEach (airport) ->
					redis_client.sadd "nearby_airports:#{data.id}", airport

parse_geocode_data = (termination_callback) ->
	parse_tsv geocode_tsv_dump, termination_callback, (data, index) ->
		if data.longitude? && data.latitude?
			redis_client.hmset "geocode:#{data.id}",
				latitude: data.latitude
				longitude: data.longitude

parse_citytown_data = (termination_callback) ->
	parse_tsv citytown_tsv_dump, termination_callback, (data, index) ->
		if data.name?
            # Normalise city-town name case, this makes it slightly easier to
            # query keys later on
			name = data.name.toTitleCase()
			redis_client.set "citytown:#{name}", data.id

redis_client.flushall (error) ->
	async.parallel [ parse_location_data, parse_geocode_data, parse_citytown_data ], ->
		redis_client.quit()
