$(function() {

	$.template ( 'error_message', 
		'<div class="alert alert-error">' +
		'<a class="close" data-dismiss="alert">&times;</a>' +
		'<strong>Error:</strong> ${statusText}' +
		'</div>'
	);

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

		$.getJSON('/geolocation/citytown', { name: name }, function (data) {
			$('.results').text(JSON.stringify(data, null, 4));
		})
		.error(function(jqXHR) {
			$.tmpl('error_message', jqXHR).appendTo('.results');
		});
	});

});
