require 'benchmark'
load './lib/GemMiner.rb'

gem_control = GemMiner.new('dropbox-api')
gem_threaded = GemMiner.new('dropbox-api')

Benchmark.bm(15) do |bench|
  # bench.report("serial:") { gem_control.get_yesterday_downloads }
  bench.report("autothreaded:") { gem_threaded.get_yesterday_downloads_autothreaded }
  bench.report("threaded (05):") { gem_threaded.get_yesterday_downloads_threaded(5) }
  bench.report("threaded (10):") { gem_threaded.get_yesterday_downloads_threaded(10) }
  bench.report("threaded (15):") { gem_threaded.get_yesterday_downloads_threaded(15) }
  bench.report("cachethreaded:") { gem_threaded.get_yesterday_downloads_cachethreaded }
end;
