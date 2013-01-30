require './pre-crawler'

after_fork do |server,worker|
  ::Wavii::PreCrawler.after_fork!
end

worker_processes 2

listen 4567
