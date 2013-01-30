#!/usr/bin/env rackup

# This file is used by Rack-based servers to start the application.

require './pre-crawler'

run Wavii::PreCrawler
