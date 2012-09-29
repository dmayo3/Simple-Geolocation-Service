async = require 'async'
{EventEmitter} = require 'events'

class Pipeline extends EventEmitter

	load_queue:
		empty: true
		saturated: false

	constructor: (load_worker, load_concurrency) ->
		@load_queue._queue = async.queue load_worker, load_concurrency

		@load_queue._queue.drain = =>
			@emit 'ready'

	start: ->
		@emit 'ready'

	submit_task: (task, callback) ->
		@load_queue._queue.push task, callback

exports.Pipeline = Pipeline
