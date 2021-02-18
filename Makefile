#
# Skeleton Build Automation
#

SHELL = /bin/sh

GIT_HOOKS_SRC  = scripts/git-hook-guard.sh
GIT_HOOKS_DEST = .git/hooks/pre-commit .git/hooks/pre-push

.PHONY: all
all:

.PHONY: init
init: composer.lock init-hooks

.PHONY: check
check: check-lint check-types check-test

.PHONY: clean
clean: clean-hooks clean-dependencies clean-test

#
# Init
#

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
	rm -fr .phpunit.cache
