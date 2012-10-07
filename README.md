# Simple Geolocation Service Demo

A very simple service for looking up geolocation information about cities and towns. This is a *Work In Progress*.

Built using node.js, Redis and CouchDB.

Redis is used to preprocess the data, which is then bulk inserted into CouchDB.

Redis is used to provide a very simple autocomplete/typeahead search function. CouchDB serves up data about a location such as latitude, longitude, and nearby airports.

A very simple web page is provided to test / demonstrate the service.

The data is provided by [Freebase](http://www.freebase.com/), in the form of large [TSV files](http://download.freebase.com/datadumps/latest/browse/location/) (Tab Separated Values). Make sure you read the [License](http://wiki.freebase.com/wiki/Data_dumps#License) if you wish to use Freebase data yourself.

## ToDo

* Deploy to AWS.
* Make it possible to search for areas / regions.
