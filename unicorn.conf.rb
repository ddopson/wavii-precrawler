require './pre-crawler'

after_fork do |server,worker|
  ::Wavii::PreCrawler.after_fork!
end

worker_processes 8
listen 4567, :tcp_nodelay => true, :backlog => 16
timeout 60
pid "log/unicorn.pid"

if ENV['RACK_ENV'] == 'production'
  puts "We are daemonizing and writing to log file 'log/crawler.log'"
  require 'fileutils'
  FileUtils.mkdir_p('log')
  stdout_path 'log/crawler.log'
  stderr_path 'log/crawler.log'
end

