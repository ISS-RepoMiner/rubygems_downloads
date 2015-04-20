require 'benchmark'
load './lib/gem_drill.rb'


def bench_threading
  gem_control = GemMiner::Drill.new(gem_name: 'dropbox-api', start_date: '2015-03-17');
  gem_threaded = GemMiner::Drill.new(gem_name: 'dropbox-api', start_date: '2015-03-17');

  Benchmark.bm(15) do |bench|
    bench.report('serial:') { gem_control.downloads }
    bench.report('autopooled:') { gem_threaded.downloads_autopool }
    bench.report('threads (05):') { gem_threaded.downloads_fixedpool(5) }
    bench.report('threads (10):') { gem_threaded.downloads_fixedpool(10) }
    bench.report('threads (15):') { gem_threaded.downloads_fixedpool(15) }
    bench.report('cachepooled:') { gem_threaded.downloads_dynamicpool }
  end
end

## BENCHTEST: day vs. month vs. year downloads
# Rehearsal ---------------------------------------------------
# one-year:         0.140000   0.010000   0.150000 (  3.400707)
# one-month:        0.050000   0.010000   0.060000 (  2.259179)
# one-day:          0.050000   0.010000   0.060000 (  2.225114)
# ------------------------------------------ total: 0.270000sec
#
#                       user     system      total        real
# one-year:         0.120000   0.010000   0.130000 (  3.051169)
# one-month:        0.060000   0.010000   0.070000 (  2.209594)
# one-day:          0.040000   0.000000   0.040000 (  1.899206)
def bench_dates
  Benchmark.bmbm(15) do |bench|
    bench.report('one-year:') do
      jem_year = GemMiner::Drill.new(gem_name: 'dropbox-api', start_date: '2014-04-17', end_date: '2015-04-17');
      jem_year.downloads_dynamicpool
    end
    bench.report('one-month:') do
      jem_month = GemMiner::Drill.new(gem_name: 'dropbox-api', start_date: '2015-03-17', end_date: '2015-04-17');
      jem_month.downloads_dynamicpool
    end
    bench.report('one-day:') do
      jem_day = GemMiner::Drill.new(gem_name: 'dropbox-api', start_date: '2015-04-17', end_date: '2015-04-17');
      jem_day.downloads_dynamicpool
    end
  end
end
