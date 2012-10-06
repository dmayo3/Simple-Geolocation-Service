cradle = require 'cradle'

cradle.setup
	host: 'localhost'
	port: 5984
	cache: false # Do not use client write-through cache
	raw: false

cradle_client = new cradle.Connection()
couchdb = cradle_client.database 'geolocation'
couchdb.create()

module.exports = couchdb
