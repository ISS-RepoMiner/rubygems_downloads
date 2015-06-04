# require './app'
require_relative 'gem_map_queue'
require_relative 'gem_drill.rb'
require_relative 'no_sql_store'
require_relative '../model/gem_version_download'
require 'concurrent'

# Wraps the mining and storing of gems
module GemMiner
  class GemWorker
    def initialize
      @db = NoSqlStore.new
    end

    def mine_and_save(gem_name, start_date, end_date)
      node = mine_gem_for_node(gem_name, start_date, end_date)
      save_node(node) if node.errors.empty?
    end

    def mine_gem_for_node(gem_name, start_date, end_date)
      jem = GemMiner::Drill.new(gem_name, start_date, end_date)
      jem.download_versions.node
    end

    def save_node(node)
      node.results.each do |version, date_downloads|
        date_downloads.each do |date, downloads|
          jem = GemMiner::GemVersionDownload.new(node.name, version, date, downloads)
          @db.save_eventually(jem)
        end
      end
      batch_save_results = @db.batch_flush
    end
  end

  class WorkerPool
    def initialize(queue_name)
      @gem_queue = GemMapQueue.new(queue_name)
    end

    def perform
      @gem_queue.poll_batch do |gems_map|
        threads = Concurrent::CachedThreadPool.new
        puts "MAP: #{gems_map}"
        gems_map.each do |gem_json|
          threads.post do
            worker = GemWorker.new
            puts "\t#{gem_json}"
            gem_h = JSON.load(gem_json)
            worker.mine_and_save(gem_h['name'], gem_h['start_date'], gem_h['end_date'])
            puts "\t--#{gem_h['name']} end"
          end
        end

        threads.shutdown
        threads.wait_for_termination
      end
    end

    def perform_async(num_engines=20)
      pool = Concurrent::CachedThreadPool.new

      num_engines.times do |engine_num|
        pool.post do
          @gem_queue.poll do |gem_json|
            worker = GemWorker.new
            puts "\t[eng #{engine_num}]#{gem_json}"
            gem_h = JSON.load(gem_json)
            worker.mine_and_save(gem_h['name'], gem_h['start_date'], gem_h['end_date'])
            puts "\t--[eng #{engine_num}]#{gem_h['name']} end"
          end
        end
      end
    end
  end
end
