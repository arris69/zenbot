# Check if this is Windows
ifneq (,$(findstring WINDOWS,$(PATH)))
WINDOWS := True
endif

# Set shell to cmd on windows
ifdef WINDOWS
SHELL := C:/Windows/System32/cmd.exe
endif

# Don't use sudo on windows
SUDO := "sudo"
ifdef WINDOWS
SUDO := 
endif

# set home dir to user's home on windows running MINGW
ifdef MSYSTEM
HOME := $(subst \,/,$(HOME))
endif

# Get the root dir of this file
ROOT_DIR := $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))

# Define the full path to this file
THIS_FILE := $(lastword $(MAKEFILE_LIST))

# Set podman-compose file selector for windows
ifneq (,$(findstring WINDOWS,$(PATH)))
DC_CONFIG=$(ROOT_DIR)/docker-compose-windows.yml
else
DC_CONFIG=$(ROOT_DIR)/docker-compose.yml
endif

# Find or create a home for sensitive environment variables
# Check my secret place
CREDS=$(HOME)/.bash/.credentials
ifneq ("$(wildcard $(CREDS))","")
CREDENTIALS := $(CREDS)
else
# Check a normal place
CREDS=$(HOME)/.credentials
ifneq ("$(wildcard $(CREDS))","")
CREDENTIALS := $(CREDS)
else
$(info $(shell "mkdir" $(CREDS)))
endif
endif

# To use arguments with make execute: make -- <command> <args>
ARGS = $(filter-out $@,$(MAKECMDGOALS))
MAKEFLAGS += --silent

list:
	sh -c "echo; $(MAKE) -p no_targets__ | awk -F':' '/^[a-zA-Z0-9][^\$$#\/\\t=]*:([^=]|$$)/ {split(\$$1,A,/ /);for(i in A)print A[i]}' | grep -v '__\$$' | grep -v 'Makefile'| sort"

#############################
# ZENBOT
#############################

list-strategies:
	podman-compose run server zenbot list-strategies $(ARGS)

list-selectors:
	podman-compose run server zenbot list-selectors $(ARGS)

backfill:
	podman-compose run server zenbot backfill $(ARGS)

sim:
	podman-compose run server zenbot sim $(ARGS)

trade:
	podman-compose run server zenbot trade $(ARGS)

paper:
	podman-compose run server zenbot trade --paper $(ARGS)

balance:
	podman-compose run server zenbot balance $(ARGS)

buy:
	podman-compose run server zenbot buy $(ARGS)

sell:
	podman-compose run server zenbot sell $(ARGS)

zenbot:
	podman-compose run server zenbot $(ARGS)

#############################
# Docker machine states
#############################
time-sync:
	docker run --rm --privileged alpine hwclock -s

up:
	$(SUDO) podman-compose --file=$(DC_CONFIG) up

start:
	podman-compose start

stop:
	podman-compose stop

state:
	podman-compose ps

rebuild:
	$(SUDO) podman-compose stop
	$(SUDO) podman-compose pull
	$(SUDO) podman-compose rm --force server
	$(SUDO) podman-compose rm --force mongodb
	-$(SUDO) podman-compose rm --force adminmongo
	$(SUDO) podman-compose build --no-cache
	$(SUDO) podman-compose --file=$(DC_CONFIG) up -d --force-recreate


shell:
	podman-compose run server /bin/sh

shellw:
	docker run -it -u root $$(podman-compose ps -q server) /bin/sh

logs:
	podman-compose logs $(ARGS)

#############################
# Argument fix workaround
#############################
%:
	@:
