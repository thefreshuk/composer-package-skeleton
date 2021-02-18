#
# Skeleton Build Automation
#

SHELL = /bin/sh

.PHONY: all
all:

.PHONY: init
init: composer.lock

.PHONY: check
check: check-lint check-types check-test

.PHONY: clean
clean:
	@rm -fr vendor
	@rm -fr .phpunit.cache
	@rm composer.lock

#
# Init
#

composer.lock: composer.json
	composer update      \
		--prefer-stable  \
		--prefer-dist    \
		--no-interaction \
		--no-progress

#
# Checking
#

.PHONY: check-lint
check-lint: composer.lock
	php vendor/bin/phpcs

.PHONY: check-types
check-types: composer.lock
	php vendor/bin/psalm

.PHONY: check-test
check-test: composer.lock
	php vendor/bin/phpunit
