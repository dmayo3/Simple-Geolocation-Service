async = require 'async'
{EventEmitter} = require 'events'

class PipelineQueues extends EventEmitter

	load:
		empty: true
		saturated: false

	save:
		empty: true
		saturated: false

	constructor: (settings) ->
		async.queue settings.load.worker, settings.load.concurrency
		async.queue settings.save.worker, settings.save.concurrency

exports.PipelineQueues = PipelineQueues
