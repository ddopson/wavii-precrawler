
.PHONY: help              # Print this menu
help:
	@cat $(CURDIR)/Makefile | egrep '^\.PHONY'

.PHONY: bundle            # Install the gem dependencies
bundle:
	bundle install

.PHONY: run               # Run the service interactively
run:
	bundle exec unicorn -c unicorn.conf.rb -Edevelopment

.PHONY: start             # Start the service as a daemon
start:
	bundle exec unicorn -c $(CURDIR)/unicorn.conf.rb -Eproduction -D

.PHONY: ps
ps:
	ps aux | grep $(CURDIR)/unicorn.conf.rb | grep -v grep

.PHONY: tail
tail:
	tail -f $(CURDIR)/log/crawler.log
