require 'benchmark'
load './lib/gem_drill.rb'

dropbox = GemMiner::Node.new('dropbox-api', '2015-03-17')
gem_control = GemMiner::Drill.new(dropbox);
gem_threaded = GemMiner::Drill.new(dropbox);

Benchmark.bm(15) do |bench|
  bench.report('serial:') { gem_control.downloads }
  bench.report('autopooled:') { gem_threaded.downloads_autopool }
  bench.report('threads (05):') { gem_threaded.downloads_fixedpool(5) }
  bench.report('threads (10):') { gem_threaded.downloads_fixedpool(10) }
  bench.report('threads (15):') { gem_threaded.downloads_fixedpool(15) }
  bench.report('cachepooled:') { gem_threaded.downloads_dynamicpool }
end;
