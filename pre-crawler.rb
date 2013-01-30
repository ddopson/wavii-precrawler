#!/usr/bin/env ruby

require 'rubygems'
# require 'headless'
require 'selenium-webdriver'
require 'sinatra/base'

module Wavii
end

class Selenium::WebDriver::Driver
  def private_bridge_object
    self.bridge
  end
end

class Wavii::PreCrawler < Sinatra::Base
  configure :production, :development do
    enable :logging
  end
  
  def self.after_fork!
    @driver = Selenium::WebDriver.for :firefox
  end

  def self.driver
    @driver
  end

  get '/news/*' do |path|
    driver = self.class.driver

    puts "Navigating to 'wavii.com/news/#{path}'"
    t_start = Time.now
    driver.navigate.to "https://wavii.com/news/#{path}"

    puts "Navigation to '#{path}' finished in #{Time.now - t_start} seconds"
    driver.private_bridge_object.setScriptTimeout(20000)
    foo = driver.execute_async_script("
      var cb = arguments[0];
      $(document).ajaxStop(function () {
        cb('done');
      });
      $.ajax('FAIL_ME');
    ")

    puts "Navigation to '#{path}' finished in #{Time.now - t_start} seconds. Foo=#{foo}"

    driver.execute_script('$("script").remove()')
    html = driver.page_source
    
    puts "Returning #{html.size} bytes to the client. Request took #{Time.now - t_start} seconds"
    return html
  end
end
