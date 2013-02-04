require './pre-crawler'

after_fork do |server,worker|
  ::Wavii::PreCrawler.after_fork!
end

worker_processes 4
listen 4567, :tcp_nodelay => true, :backlog => 16
timeout 60
pid "log/unicorn.pid"

if ENV['RACK_ENV'] == 'production'
  logger Logger.new('log/crawler.log')
end

