class TsvParser
	constructor: (@file) ->
		@header = []

	run: (terminate_callback) ->
		csv().
			fromPath(@file,
				delimiter: '\t'
				quote: ''
		).on('data', (data, index) ->

			if index % 10000 == 0
				console.log '.'

			if index == 0
				@header = data
			else
				row = {}

				data.forEach (column, i) ->
					row[@header[i]] = column
				, this

				if index < 5
					console.log(row)

		).on('end', (count) ->
			console.log "Number of lines: #{count}"
			terminate_callback()
		).on('error', (error) ->
			console.log error.message
		)

exports.TsvParser = TsvParser
