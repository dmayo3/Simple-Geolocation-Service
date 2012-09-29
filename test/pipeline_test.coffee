# Chai assertions
chai = require 'chai'
sinon_chai = require 'sinon-chai'
chai.use(sinon_chai)
should = chai.should()
# Sinon.JS mocking
sinon = require 'sinon'

{Pipeline} = require('../src/pipeline')

describe 'Pipeline', ->

	beforeEach ->
		@load_worker = sinon.stub()
		@load_concurrency = 2
		@pipeline = new Pipeline(@load_worker, @load_concurrency)

	describe 'load queue', ->

		beforeEach ->
			@load_queue = @pipeline.load_queue

		it 'should start in the empty, unsaturated state', ->
			@load_queue.empty.should.be.true
			@load_queue.saturated.should.be.false

	describe 'when started', ->

		it 'should fire ready event', (done) ->
			@pipeline.once 'ready', ->
				done()
			@pipeline.start()

	describe 'when submitting tasks', ->
		
		beforeEach ->
			@task = { data: 'foo' }

		it 'should run each task', (done) ->
			@load_worker.yields(null, @task)

			@pipeline.submit_task @task, (error, result) =>
				error?.should.be.false
				result.should.equal @task
				@load_worker.should.have.been.calledWith @task, sinon.match.func
				done()

		it 'should call ready when existing tasks have been processed', (done) ->
			@load_worker.yields(null, @task)

			@pipeline.once 'ready', =>
				@load_worker.should.have.been.calledWith @task, sinon.match.func
				@load_worker.should.have.been.calledThrice
				done()

			@pipeline.submit_task @task, ->
			@pipeline.submit_task @task, ->
			@pipeline.submit_task @task, ->
