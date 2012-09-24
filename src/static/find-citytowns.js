$(function() {

	$('.typeahead').typeahead({
	    source: function (query, callback) {
	        return $.getJSON('/geolocation/citytowns/find', { query: query }, function (data) {
	            return callback(data);
	        });
	    }
	});

	$('.form-search').submit(function(e) {
		e.preventDefault();

		var name = $(this).find('.search-query').val();

		$.getJSON("/geolocation/citytown", { name: name }, function (data) {
			$(".results").text(JSON.stringify(data, null, 4));
		});
	});

});
