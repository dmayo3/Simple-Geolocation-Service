BUILD_DIR = build
DEBUG = --debug --debug-brk

all: run-populate-couchdb

run-populate-couchdb: compile
	node build/populate_couchdb.js

run-load-freebase-data: compile
	node build/load_freebase_data.js

compile:
	coffee --compile --lint --output ${BUILD_DIR} src

clean:
	rm -rf ${BUILD_DIR}
