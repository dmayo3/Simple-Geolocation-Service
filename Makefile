BUILD_DIR = build
DEBUG = --debug --debug-brk

all: run

run: compile
	node build/load_freebase_data.js

compile:
	coffee --compile --lint --output ${BUILD_DIR} src

clean:
	rm -rf ${BUILD_DIR}
