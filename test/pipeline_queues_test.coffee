# Chai assertions
chai = require 'chai'
sinon_chai = require 'sinon-chai'
chai.use(sinon_chai)
should = chai.should()
# Sinon.JS mocking
sinon = require 'sinon'
async = require 'async'

{PipelineQueues} = require '../src/pipeline_queues'

describe 'PipelineQueues', ->

	beforeEach ->
		sinon.stub async, 'queue'

		@settings =
			load:
				worker: sinon.stub()
				concurrency: 2
			save:
				worker: sinon.stub()
				concurrency: 5

		@queues = new PipelineQueues @settings

	afterEach ->
		async.queue.restore()

	[ 'load', 'save' ].forEach (queue) ->

		describe "initial state of #{queue} queue", ->

			it 'should be empty', ->
				@queues[queue].empty.should.be.true

			it 'should not be saturated', ->
				@queues[queue].saturated.should.be.false

			it "should use the #{queue} worker function to process tasks", ->
				async.queue.should.have.been.calledWith @settings[queue].worker, sinon.match.any

			it "should process #{queue} tasks in parallel", ->
				async.queue.should.have.been.calledWith sinon.match.any, @settings[queue].concurrency 				
