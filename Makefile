PROJECTNAME=$(shell basename "$(PWD)")
VERSION=-ldflags="-X main.Version=$(shell git describe --tags)"


.PHONY: help run build install
all: help

help: Makefile
	@echo
	@echo "Choose a make command to run in "$(PROJECTNAME)":"
	@echo
	@$(MAKE) -pRrq -f $(lastword $(MAKEFILE_LIST)) : 2>/dev/null | awk -v RS= -F: '/^# File/,/^# Finished Make data base/ {if ($$1 !~ "^[#.]") {print $$1}}' | sort | egrep -v -e '^[^[:alnum:]]' -e '^$@$$'
	@echo

get:
	@echo "  >  \033[32mDownloading & Installing all the modules...\033[0m "
	go mod tidy && go mod download

get-lint:
	curl -sfL https://install.goreleaser.com/github.com/golangci/golangci-lint.sh | sh -s v1.31.0

.PHONY: lint
lint:
	if [ ! -f ./bin/golangci-lint ]; then \
		$(MAKE) get-lint; \
	fi;
	./bin/golangci-lint run ./... --timeout 5m0s

lint-fix:
	if [ ! -f ./bin/golangci-lint ]; then \
		$(MAKE) get-lint; \
	fi;
	./bin/golangci-lint run ./... --timeout 5m0s --fix

build:
	@echo "  >  \033[32mBuilding binary...\033[0m "
	env GOARCH=amd64 go build -o ./build/libp2p-node $(VERSION)

install:
	@echo "  >  \033[32mInstalling bridge...\033[0m "
	go install $(VERSION)

## Runs go test for all packages
test:
	@echo "  >  \033[32mRunning tests...\033[0m "
	go test -p 1 -coverprofile=cover.out -v `go list ./...

clean:
	rm -rf build/