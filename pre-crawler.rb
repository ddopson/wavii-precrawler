#!/usr/bin/env ruby

require 'rubygems'
require 'sinatra/base'
require 'selenium-webdriver'


module Wavii
end


class Selenium::WebDriver::Driver
  def private_bridge_object
    @bridge
  end
end


class Wavii::PreCrawler < Sinatra::Base
  BASE_URL = 'https://wavii.com'
  configure :development, :production do
    enable :logging
  end
  
  def self.after_fork!
    if RUBY_PLATFORM.match /linux/
      require 'headless'
      headless = Headless.new
      headless.start
    end
    profile = Selenium::WebDriver::Firefox::Profile.new
    profile['permissions.default.stylesheet'] = 2
    profile['permissions.default.image'] = 2
    profile['dom.ipc.plugins.enabled.libflashplayer.so'] = 'false'

    @driver = Selenium::WebDriver.for(:firefox, profile: profile)
  end

  def self.driver
    @driver
  end

  get '/**' do |path, id|
    driver = self.class.driver

    logger.info "path=#{path}, id=#{id}"
    url = "#{BASE_URL}/#{path}/#{id}"

    logger.info "Step1: Navigating to '#{url}'"
    t_start = Time.now
    driver.navigate.to "#{url}"

    t_nav = Time.now
    logger.info "Step2: Navigation to '#{url}' finished in #{t_nav - t_start} seconds. Waiting for AJAX"
    begin
      driver.private_bridge_object.setScriptTimeout(20000)
      foo = driver.execute_async_script("
        var cb = arguments[0];
        $(document).ajaxStop(function () {
          cb('done');
        });
        $.ajax('FAIL_ME');
      ")

      logger.info "Step3: Navigation+AJAX to '#{url}' finished in #{Time.now - t_nav} seconds."

      driver.execute_script('$("script").remove()')
    rescue Exception => e
      logger.warn "Url '#{url}' generated error #{e.message}"
    end
    html = driver.page_source
    
    logger.info "Returning #{html.size} bytes to the client. Request for '#{url}' took #{Time.now - t_start} seconds"
    return html
  end
end
