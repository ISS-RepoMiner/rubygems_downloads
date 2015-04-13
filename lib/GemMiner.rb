require 'gems'
require 'concurrent'

# Gets gem information from rubygems.org (wrapper for Gems gem)
class GemMiner
  attr_reader :versions, :version_dates

  # initialize the class with the gem_name, input and output formulation
  def initialize(gem_name)
    @gem_name = gem_name
    @all_downloads=Hash.new{|h,k| h[k] = Hash.new(&h.default_proc)}
    @yesterday_downloads=Hash.new{|h,k| h[k] = Hash.new(&h.default_proc)}
    get_all_versions
    # @gem_info={}
  end

  # scan all the versions of a gem
  def get_all_versions
    @versions ||= Gems.versions @gem_name
    create_vers_list
  end

  def create_vers_list
    @version_dates = {}
    @versions.map do |ver|
      @version_dates[ver['number']] = ver['built_at']
    end
    @version_dates
  end

  # check the downloads of a version series
  def get_ver_downloads(ver)
    Gems.downloads @gem_name, ver
  end

  def get_ver_history_downloads_series(ver)
    Gems.downloads @gem_name, ver, @versions[ver],Date.today-1
  end

  # check date downloads for specific version,date format "2014-12-05"
  def get_ver_downloads_by_date(ver,date)
    Gems.downloads @gem_name, ver, date, date
  end

  # get yesterday downloads of a specific version
  def get_ver_yesterday_downloads (ver)
    downloads = Gems.downloads @gem_name, ver, Date.today-1, Date.today-1
  end

  # save the downloads data to a structured hash_table
  def save_all_downloads(downloads,ver)
    downloads.each do |k,v|
      @all_downloads[@gem_name][ver][k] = v
    end
  end

  def save_yesterday_downloads(downloads, ver)
    downloads.each do |k,v|
      @yesterday_downloads[@gem_name][ver][k] = v
    end
  end

  # call the method to get what needed in a hash format
  def get_versions_downloads_list
    @version_dates.each do |ver, built_at|
      downloads = get_ver_history_downloads_series(ver)
      save_all_downloads(downloads,ver)
    end
    @all_downloads
  end

  # call the method to get the updating downloads time ( yesterday )
  def get_yesterday_downloads
    @version_dates.keys.each do |ver|
      downloads = get_ver_yesterday_downloads(ver)
      save_yesterday_downloads(downloads,ver)
    end
    @yesterday_downloads
  end

  def get_yesterday_downloads_autothreaded
    threads = @version_dates.keys.map do |ver|
      Thread.new do
        downloads = get_ver_yesterday_downloads(ver)
        save_yesterday_downloads(downloads,ver)
      end
    end
    threads.map(&:join)
    @yesterday_downloads
  end

  def get_yesterday_downloads_threaded(num_threads=15)
    threads = Concurrent::FixedThreadPool.new(num_threads)
    lock = Mutex.new

    @version_dates.keys.each do |ver|
      threads.post do
        downloads = get_ver_yesterday_downloads(ver)
        lock.synchronize do
          save_yesterday_downloads(downloads, ver)
        end
      end
    end
    threads.shutdown
    threads.wait_for_termination
    @yesterday_downloads
  end

  def get_yesterday_downloads_cachethreaded
    threads = Concurrent::CachedThreadPool.new
    lock = Mutex.new

    @version_dates.keys.each do |ver|
      threads.post do
        downloads = get_ver_yesterday_downloads(ver)
        lock.synchronize do
          save_yesterday_downloads(downloads, ver)
        end
      end
    end
    threads.shutdown
    threads.wait_for_termination
    @yesterday_downloads
  end

  # related information
  def get_info
    gem_info = Gems.info @gem_name
    gem_info
  end

  # historical dependencies
  def get_dependencies
    gem_dependencies = Gems.dependencies [@gem_name]
    gem_dependencies
  end

end
