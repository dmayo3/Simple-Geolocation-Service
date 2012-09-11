BUILD_DIR = build
DEBUG = --debug --debug-brk

all: compile

compile:
	coffee --compile --lint --output ${BUILD_DIR} src

clean:
	rm -rf ${BUILD_DIR}
