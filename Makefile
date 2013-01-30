
.PHONY: help              # Print this menu
help:
	@cat $(CURDIR)/Makefile | egrep '^\.PHONY'

.PHONY: bundle            # Install the gem dependencies
bundle:
	bundle install

.PHONY: run               # Run the service interactively
run:
	bundle exec unicorn -c unicorn.conf.rb

.PHONY: start             # Start the service as a daemon
start:
	bundle exec unicorn -c unicorn.conf.rb -D 

