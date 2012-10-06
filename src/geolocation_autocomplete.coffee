# Simple web service for searching and looking up geolocation data

String.prototype.toTitleCase = require('./common').toTitleCase
redis_client = require './redis_connection'
couchdb = require './cradle_connection'
bricks = require 'bricks'
fs = require 'fs'


app_server = new bricks.appserver()

# Add request plugin for parameter extraction
app_server.addRoute '^/', app_server.plugins.request

app_server.addRoute '.+', app_server.plugins.filehandler, { basedir: './build/static' }

write_json = (response, doc) ->
	response.write JSON.stringify(doc)
	response.setHeader 'Content-type: application/json; charset=utf-8'
	response.end()

# Find a city/town by partial name (used for autocomplete/typeahead)
app_server.addRoute '^/geolocation/citytowns/find$', (request, response) ->
	query = request.param('query').toTitleCase()

	console.log "Searching for citytown:#{query}*..."

	redis_client.keys "citytown:#{query}*", (error, keys) ->
		limitedKeys = keys.slice(0, 8)
		results = limitedKeys.map (key) -> key.replace /^citytown:/, ''

		write_json(response, results.slice(0, 10))

# Lookup city/town information by name
app_server.addRoute '^/geolocation/citytown$', (request, response) ->
	name = request.param('name').toTitleCase()

	redis_client.get "citytown:#{name}", (error, id) ->
		couchdb.get id, (err, doc) ->
			# Filter out couchbase metadata before sending to client
			delete doc[property] for property of doc when property.match /^_/
			write_json(response, doc)

app_server.addRoute '.+', app_server.plugins.fourohfour

app_server.addEventHandler 'route.fatal', (error) ->
	console.log "Routing error: #{error}"

app_server.addEventHandler 'run.fatal', (error) ->
	console.log "Route handler error: #{error}"

app_server.createServer().listen 3000
