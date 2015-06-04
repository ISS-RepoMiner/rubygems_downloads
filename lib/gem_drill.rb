require 'gems'
require 'concurrent'

module GemMiner
  # Node to mine: name of gem, start and end dats (date formats: "YYYY-MM-DD")
  Node = Struct.new(:name, :start_date, :end_date, :results, :errors) do
    def initialize(*)
      super
      self.results = Hash.new{ |h,k| h[k] = Hash.new(&h.default_proc) }
      self.errors = []
    end
  end

  # Gets gem information from rubygems.org (wrapper for Gems gem)
  class Drill
    attr_reader :versions, :version_dates, :node

    # initialize the class with GemNode structure
    def initialize(gem_name,
                   start_date = (Date.today-1).to_s,
                   end_date = (Date.today-1).to_s)
      @node = Node.new(gem_name, start_date, end_date)
      @lock = Mutex.new
      @all_downloads = Hash.new{ |h,k| h[k] = Hash.new(&h.default_proc) }
      store_all_versions
    rescue => e
      @node.errors << e
    end

    # return all versions of a gem
    def store_all_versions
      @versions = Gems.versions @node.name
      raise "Gem '#{@node.name}' not found" unless @versions.is_a? Array
      store_versions_dates
    rescue => e
      @node.errors << e
    end

    def store_versions_dates
      @version_dates = {}
      @versions.map do |ver|
        @version_dates[ver['number']] = ver['built_at']
      end
      @version_dates
    end

    # check the downloads of a version series
    def get_ver_downloads(ver)
      Gems.downloads @node.name, ver
    end

    # def get_ver_history_downloads_series(ver)
    #   Gems.downloads @node.name, ver, @versions[ver], Date.today-1
    # end

    # check date downloads for specific version, by date range
    def get_ver_downloads_by_dates(ver)
      end_date = @node.end_date || @node.start_date
      downloads = Gems.downloads(@node.name, ver, @node.start_date, end_date)
      downloads.is_a?(String) ? fail("No gem found") : downloads
    rescue => e
      @node.errors << e
    end

    def save_downloads(downloads, ver)
      downloads.each do |date, number|
        @lock.synchronize do
          @node.results[ver][date] = number if number > 0
        end
      end
    end

    # call the method to get what needed in a hash format
    # def get_versions_downloads_list
    #   @version_dates.each do |ver, built_at|
    #     downloads = get_ver_history_downloads_series(ver)
    #     save_all_downloads(downloads, ver)
    #   end
    #   @all_downloads
    # end

    def download_versions
      pool = Concurrent::CachedThreadPool.new
      @version_dates.keys.each do |version|
        pool.post(version) do |version_for_thread|
          downloads = get_ver_downloads_by_dates(version_for_thread)
          save_downloads(downloads, version_for_thread)
        end
      end
      pool.shutdown
      pool.wait_for_termination
      self
    end

    # related information
    def get_info
      gem_info = Gems.info @node.name
      gem_info
    end

    # historical dependencies
    def get_dependencies
      gem_dependencies = Gems.dependencies [@node.name]
      gem_dependencies
    end
  end

  ## LEGACY METHODS
  #
  # call the method to get the updating downloads time ( yesterday )
  # def downloads
  #   @version_dates.keys.each do |ver|
  #     downloads = get_ver_yesterday_downloads(ver)
  #     save_downloads(downloads, ver)
  #   end
  #   self
  # end
  #
  # def downloads_autopool
  #   threads = @version_dates.keys.map do |version|
  #     Thread.new(version) do |version_th|
  #       downloads = get_ver_downloads_by_dates(version_th)
  #       save_downloads(downloads, version_th)
  #     end
  #   end
  #   threads.map(&:join)
  #   self
  # end
  #
  # def downloads_fixedpool(num_threads=15)
  #   threads = Concurrent::FixedThreadPool.new(num_threads)
  #   @version_dates.keys.each do |version|
  #     threads.post(version) do |version_th|
  #       downloads = get_ver_downloads_by_dates(version_th)
  #       save_downloads(downloads, version_th)
  #     end
  #   end
  #   threads.shutdown
  #   threads.wait_for_termination
  #   self
  # end
end
