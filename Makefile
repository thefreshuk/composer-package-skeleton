#
# Skeleton Build Automation
#

SHELL = /bin/sh

#
# Project Details
#

export PROJECT_NAME      = Skeleton
export PROJECT_AUTHOR    = James W. Dunne
export PROJECT_COPYRIGHT = 2021 The Fresh

DOCS_PORT ?= 8889
DOCS_HOST ?= localhost
DOCS_ADDR ?= $(DOCS_HOST):$(DOCS_PORT)

PARALLELISM = 8

GIT_HOOKS_SRC  = scripts/git-hook-guard.sh
GIT_HOOKS_DEST = .git/hooks/pre-commit .git/hooks/pre-push

VENV_PATH     = .venv
VENV_BIN_PATH = $(VENV_PATH)/bin
VENV_PIP      = $(VENV_BIN_PATH)/pip
VENV_PY       = $(VENV_BIN_PATH)/python
VENV_SPHINX   = $(VENV_BIN_PATH)/sphinx-build

BUILD_PATH = build
BUILD_DOCS = $(BUILD_PATH)/docs

.PHONY: all
all: check

.PHONY: init
init: init-composer init-hooks init-py

.PHONY: check
check: check-lint check-types check-test check-mutations check-dependencies

.PHONY: fix
fix: fix-lint fix-types

.PHONY: clean
clean: clean-hooks clean-dependencies clean-test clean-py

.PHONY: docs
docs: | $(BUILD_DOCS)
	$(VENV_SPHINX) "docs" "$(BUILD_DOCS)"

#
# Initializing
#

.PHONY: init-composer
init-composer: composer.lock

composer.lock: composer.json
	composer update      \
		--prefer-stable  \
		--prefer-dist    \
		--no-interaction \
		--no-progress

.PHONY: init-hooks
init-hooks: $(GIT_HOOKS_DEST)

$(GIT_HOOKS_DEST): $(GIT_HOOKS_SRC)
	ln -s $(realpath $<) $@
	chmod +x $@

.PHONY: init-py
init-py: $(VENV_PY)
	$(VENV_PIP) install -r requirements.txt

$(VENV_PY):
	python -m venv $(VENV_PATH)

#
# Checking
#

.PHONY: check-lint
check-lint: init-composer
	php vendor/bin/phpcs --parallel=$(PARALLELISM)

.PHONY: check-types
check-types: init-composer
	php vendor/bin/psalm --no-diff --threads=$(PARALLELISM)

.PHONY: check-test
check-test: init-composer
	php vendor/bin/paratest --processes=$(PARALLELISM)

.PHONY: check-mutations
check-mutations: init-composer
	php vendor/bin/infection --show-mutations --threads=$(PARALLELISM)

.PHONY: check-dependencies
check-dependencies: init-composer
	composer show --direct --outdated --strict --minor-only

.PHONY: check-performance
check-performance: init-composer
	php vendor/bin/phpbench run

#
# Documenting
#

.PHONY: docs-serve
docs-serve: docs
	php -S $(DOCS_ADDR) -t $(BUILD_DOCS)

$(BUILD_DOCS):
	mkdir -p $@

#
# Fixing
#

.PHONY: fix-lint
fix-lint: composer.lock
	-php vendor/bin/phpcbf

.PHONY: fix-types
fix-types: composer.lock
	php vendor/bin/psalter --issues=all

#
# Cleaning
#

.PHONY: clean-hooks
clean-hooks:
	rm -f $(GIT_HOOKS_DEST)

.PHONY: clean-dependencies
clean-dependencies:
	rm -fr vendor
	rm -fr composer.lock

.PHONY: clean-test
clean-test:
	rm -fr .phpunit.cache

.PHONY: clean-py
clean-py:
	rm -fr .venv
