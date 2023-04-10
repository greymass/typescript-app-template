SHELL := /bin/bash
PATH  := ./node_modules/.bin:$(PATH)
BIN := ./node_modules/.bin

SRC_FILES := $(shell find src -name '*.ts')

define VERSION_TEMPLATE
"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.default = "$(shell node -p 'require("./package.json").version')-$(shell git rev-parse --short HEAD)";
endef

all: lib

export VERSION_TEMPLATE
lib: $(SRC_FILES) node_modules tsconfig.json
	tsc -p tsconfig.json --outDir lib && \
	echo "$$VERSION_TEMPLATE" > lib/version.js && \
	touch lib

.PHONY: dev
dev: node_modules
	@onchange -k -i 'src/**/*.ts' 'config/*' -- ts-node src/index.ts | bunyan -o short

.PHONY: check
check: node_modules
	@${BIN}/eslint src --ext .ts --max-warnings 0 --format unix && echo "Ok"

.PHONY: format
format: node_modules
	@${BIN}/eslint src --ext .ts --fix

.PHONY: test
test: node_modules
	@mocha -u tdd -r ts-node/register --extension ts test/**/*.ts test/**/**/*.ts

node_modules: package.json
	yarn install --non-interactive --frozen-lockfile

.PHONY: clean
clean:
	rm -rf lib/

.PHONY: distclean
distclean: clean
	rm -rf node_modules/
