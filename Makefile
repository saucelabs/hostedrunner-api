GOBIN	:= $(shell pwd)/bin
GO 		?= $(shell which go)
.DEFAULT_GOAL := help

LDFLAGS 	:= "-extldflags '-static'"

##@ Build Dependencies

SHELL=/bin/sh
.SHELLFLAGS = -e -c

## Location to install dependencies to
LOCALBIN ?= $(shell pwd)/bin
$(LOCALBIN):
	mkdir -p $(LOCALBIN)

## Tool Binaries
GOLANGCI ?= $(LOCALBIN)/golangci-lint

## Tool Versions
GOLANGI_LINT_VERSION ?= v1.50.1
OAPI_CODEGEN_VERSION ?= "1.12.4"

OAPI_CODEGEN_FOUND := $(shell oapi-codegen --version 2> /dev/null)
.PHONY: oapi_codegen
oapi_codegen: ## Install oapi-codegen globally
ifndef OAPI_CODEGEN_FOUND
	go install github.com/deepmap/oapi-codegen/cmd/oapi-codegen@v$(OAPI_CODEGEN_VERSION)
else
	echo $(OAPI_CODEGEN_FOUND)
endif

GOLANGCI_LINT_INSTALL_SCRIPT ?= "https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh"
.PHONY: golangci
golangci: $(GOLANGCI)
$(GOLANGCI): $(LOCALBIN)
	test -s $(LOCALBIN)/golangci-lint || { curl -Ss $(GOLANGCI_LINT_INSTALL_SCRIPT) -o $(LOCALBIN)/install.sh && \
	bash $(LOCALBIN)/install.sh -b $(LOCALBIN) $(GOLANGI_LINT_VERSION); }

help: ## Display this help screen
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
.PHONY: help

generate: oapi_codegen ## Generate code
	$(GO) generate ./...
.PHONY: generate

fmt: golangci generate
	$(GOLANGCI) run -v -c .golangci-fmt.yml --fix ./...
.PHONY: fmt

lint: golangci generate ## Lint
	$(GOLANGCI) run -v -c .golangci.yml ./...
.PHONY: lint
