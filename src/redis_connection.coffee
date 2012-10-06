redis = require 'redis'

client = redis.createClient 6379

client.on 'error', (error) ->
	console.error "Redis error: #{error}"
	client.quit()
	throw error

module.exports = client
