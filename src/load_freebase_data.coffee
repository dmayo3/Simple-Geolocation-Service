csv = require('csv')
redis = require('redis')
TsvParser = require('./tsv_parser')

redis_client = redis.createClient(6379)

freebase_tsv_dump = __dirname + '/../location.tsv'

location_parser = new TsvParser(freebase_tsv_dump)

location_parser.run ->
	redis_client.quit()

# name	id	usbg_name	geolocation	contains	gnis_feature_id	gns_ufi	containedby	adjoin_s	area	time_zones	people_born_here	geometry	adjectival_form	coterminous_with	near	inside	street_address	point	shape	events	unlocode	nearby_airports	partially_contains	partially_containedby