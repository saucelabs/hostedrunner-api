GOBIN	:= $(shell pwd)/bin
GO 		?= $(shell which go)

LDFLAGS 	:= "-extldflags '-static'"

##@ Build Dependencies

SHELL=/bin/sh
.SHELLFLAGS = -e -c

help: ## Display this help screen
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
.PHONY: help

install-tools: ## Download & install go tools like golangci-lint
	./install-tools.sh
.PHONY: install-tools

generate: ## Generate boilerplate
	$(GO) generate ./...
.PHONY: generate
