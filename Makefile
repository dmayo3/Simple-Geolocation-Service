SRC_DIR = src
BUILD_DIR = build
DEBUG = --debug --debug-brk

.PHONY: all test clean

all: populate-data delete-unused-data run-geolocation-autocomplete

populate-data: clean run-load-freebase-data run-populate-couchdb

run-load-freebase-data: compile
	node build/load_freebase_data.js

run-populate-couchdb: compile
	node build/populate_couchdb/populate_couchdb.js

run-geolocation-autocomplete: compile
	node build/geolocation_autocomplete.js

compile: clean-files compile-coffeescript copy-html

compile-coffeescript:
	coffee --compile --lint --output ${BUILD_DIR} ${SRC_DIR}

test:
	./node_modules/.bin/mocha

test-continuous:
	./node_modules/.bin/mocha --watch --growl

copy-html:
	cp -r ${SRC_DIR}/static ${BUILD_DIR}/static

clean: flush-redis drop-couchdb clean-files

clean-files:
	rm -rf ${BUILD_DIR}

flush-redis:
	redis-cli FLUSHALL

drop-couchdb:
	curl -X DELETE localhost:5984/geolocation

delete-unused-data:
	echo "Removing unused data from Redis"
	redis-cli KEYS "location:*" | xargs redis-cli DEL
	redis-cli KEYS "geocode:*" | xargs redis-cli DEL
