SRC_DIR = src
BUILD_DIR = build
DEBUG = --debug --debug-brk

all: populate-data run-geolocation-autocomplete

populate-data: clean run-load-freebase-data run-populate-couchdb

run-load-freebase-data: compile
	node build/load_freebase_data.js

run-populate-couchdb: compile
	node build/populate_couchdb.js

run-geolocation-autocomplete: compile
	node build/geolocation_autocomplete.js

compile: compile-coffeescript copy-html

compile-coffeescript:
	coffee --compile --lint --output ${BUILD_DIR} ${SRC_DIR}

copy-html:
	cp -r ${SRC_DIR}/static ${BUILD_DIR}/static

clean: flush-redis drop-couchdb clean-files

clean-files:
	rm -rf ${BUILD_DIR}

flush-redis:
	redis-cli FLUSHALL

drop-couchdb:
	curl -X DELETE localhost:5984/geolocation
