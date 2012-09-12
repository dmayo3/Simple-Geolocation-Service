redis = require 'redis'
csv = require 'csv'
async = require 'async'

redis_client = redis.createClient(6379)

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
		console.log '.' if index % 50000 == 0
		data_callback(data, index)
	).on('end', (count) ->
		console.log "Parsed: #{count} lines from #{file}"
		termination_callback()
	).on('error', (error) ->
		console.log error.message
	)

save = (data, namespace, key) ->
	redis_client.set "#{namespace}:#{data.id}:#{key}", data[key]

parse_location_data = (termination_callback) ->
	parse_tsv location_tsv_dump, termination_callback, (data, index) ->
		if data.name?
			save data, 'location', 'name'
			save data, 'location', 'geolocation' if data.geolocation?
			save data, 'location', 'containedby' if data.containedby?

			if data.nearby_airports?
				nearby_airports = data.nearby_airports.split ','
				nearby_airports.forEach (airport) ->
					redis_client.sadd "location:#{data.id}:nearby_airports", airport

parse_geocode_data = (termination_callback) ->
	parse_tsv geocode_tsv_dump, termination_callback, (data, index) ->
		if data.longitude? && data.latitude?
			save data, 'geocode', 'latitude'
			save data, 'geocode', 'longitude'

parse_citytown_data = (termination_callback) ->
	parse_tsv citytown_tsv_dump, termination_callback, (data, index) ->
		if data.name?
			save data, 'citytown', 'name'

async.parallel [ parse_location_data, parse_geocode_data, parse_citytown_data ], ->
	redis_client.quit()
