require 'benchmark'
require_relative '../app.rb'

NUM_BATCHES = 5
BATCH_SIZE = 20

def fake_gem_batches(num_batches, batch_size)
  letters = ('a'..'z').take(26)

  num_batches.times.map do
    batch_size.times.map do
      letters.sample(7).join
    end
  end
end

def bench_puts
  db = NoSqlStore.new
  today = Date.today.to_s

  gems_serial = fake_gem_batches(NUM_BATCHES, BATCH_SIZE)
  gems_serial_th = fake_gem_batches(NUM_BATCHES, BATCH_SIZE)
  gem_batches = fake_gem_batches(NUM_BATCHES, BATCH_SIZE)
  batch_save_results = []

  Benchmark.bm(20) do |bench|
    bench.report("put_item (serial)") do
      gems_serial.each do |batch|
        batch.each do |gem_name|
          jem = GemMiner::GemVersionDownload.new(gem_name, '0.1.0', today, 3)
          db.save(jem)
        end
      end
    end

    bench.report("put_item (threaded)") do
      threads = []
      gems_serial_th.each do |batch|
        batch.each do |gem_name|
          threads << Thread.new do
            jem = GemMiner::GemVersionDownload.new(gem_name, '0.1.0', today, 3)
            db.save(jem)
          end
        end
      end
      threads.map(&:join)
    end

    bench.report("batch_write") do
      gem_batches.each do |batch|
        batch.each do |gem_name|
          jem = GemMiner::GemVersionDownload.new(gem_name, '0.1.0', today, 3)
          db.add_to_batch(jem)
        end
        batch_save_results << db.batch_flush
      end
    end
  end

  batch_save_results
end

def demo_batch_adds
  dropbox = GemMiner::GemVersionDownload.new('dropbox-api', '0.4.6', Date.today.to_s, 4)
  citesight = GemMiner::GemVersionDownload.new('citesight', '0.1.0', Date.today.to_s, 3)

  db = NoSqlStore.new
  db.add_to_batch(dropbox)
  db.add_to_batch(citesight)
  results = db.batch_flush
end
