exports.toTitleCase = ->
    @replace /\w\S*/g, (txt) ->
    	txt.charAt(0).toUpperCase() + txt.substr(1).toLowerCase()
