#!/usr/bin/env ruby

require 'rubygems'
# require 'headless'
require 'selenium-webdriver'
require 'sinatra/base'

module Wavii
end

class Selenium::WebDriver::Driver
  def private_bridge_object
    @bridge
  end
end

class Wavii::PreCrawler < Sinatra::Base
  configure :production, :development do
    enable :logging
  end
  
  def self.after_fork!
    if RUBY_PLATFORM.match /linux/
      require 'headless'
      headless = Headless.new
      headless.start
    end
    @driver = Selenium::WebDriver.for :firefox
  end

  def self.driver
    @driver
  end

  get '/*/*' do |path, id|
    driver = self.class.driver

    puts "Navigating to 'local.wavii.com:3000/#{path}/#{id}'"
    t_start = Time.now
    driver.navigate.to "http://local.wavii.com:3000/#{path}/#{id}"

    puts "Navigation to '#{path}/#{id}' finished in #{Time.now - t_start} seconds. Waiting for AJAX"
    driver.private_bridge_object.setScriptTimeout(20000)
    foo = driver.execute_async_script("
      var cb = arguments[0];
      $(document).ajaxStop(function () {
        cb('done');
      });
      $.ajax('FAIL_ME');
    ")

    puts "Navigation+AJAX to '#{path}/#{id}' finished in #{Time.now - t_start} seconds."

    driver.execute_script('$("script").remove()')
    html = driver.page_source
    
    puts "Returning #{html.size} bytes to the client. Request took #{Time.now - t_start} seconds"
    return html
  end
end
