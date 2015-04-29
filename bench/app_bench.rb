# SNS Message:
sns_msg = {"QueueName"=>"GemMap"}.to_json

# SQS Messages:
q = GemMiner::GemMapQueue.new('GemMap')
q.send_message({"name"=>"dropbox-api", "start_date"=>"2015-04-28", "end_date"=>"2015-04-28"}.to_json);
q.send_message({"name"=>"nokogiri", "start_date"=>"2015-04-28", "end_date"=>"2015-04-28"}.to_json);
q.send_message({"name"=>"citesight", "start_date"=>"2015-04-28", "end_date"=>"2015-04-28"}.to_json);

require 'benchmark'
puts(Benchmark.measure { app.mine_gems_from_queue('GemMap') })
