# Chai assertions
chai = require 'chai'
sinon_chai = require 'sinon-chai'
chai.use(sinon_chai)
should = chai.should()
# Sinon.JS mocking
sinon = require 'sinon'

load_location = require('../src/populate_couchdb/load_location')

valid_citytown_id = '/m/02z8x6d' # Mediana de Voltoya

describe 'load_location', ->

	it 'should load a location from Redis', (done) ->

		load_location valid_citytown_id, (error, location) ->
			should.not.exist error
			
			location._id.should.be.equal valid_citytown_id
			location.name.should.be.equal 'Mediana de Voltoya'
			location.containedby.should.be.equal 'Spain'

			location.geolocation.should.deep.equal
				latitude: '40.7'
				longitude: '-4.56666666667'
			
			location.nearby_airports.should.deep.equal []

			done()
