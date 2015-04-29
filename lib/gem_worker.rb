# require './app'
require_relative 'gem_map_queue'
require_relative 'gem_drill.rb'
require_relative 'no_sql_store'
require_relative '../model/gem_version_download'

# Wraps the mining and storing of gems
module GemMiner
  class GemWorker
    def initialize
      @db = NoSqlStore.new
    end

    def mine_and_save(gem_name, start_date, end_date)
      node = mine_gem_for_node(gem_name, start_date, end_date)
      save_node(node)
    end

    def mine_gem_for_node(gem_name, start_date, end_date)
      jem = GemMiner::Drill.new(gem_name, start_date, end_date)
      jem.downloads_dynamicpool.node
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
      worker = GemWorker.new
      @gem_queue.poll_batch do |gems_map|
        gems_map.each do |gem_json|
          puts "\t#{gem_json}"
          gem_h = JSON.load(gem_json)
          worker.mine_and_save(gem_h['name'], gem_h['start_date'], gem_h['end_date'])
        end
      end
    end
  end
end
