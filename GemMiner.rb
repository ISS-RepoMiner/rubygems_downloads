require 'gems'

=begin
usage:
first create a ~/.gem/credentials as below
---
:rubygems_api_key: XXXXXXX
=end

# get { gem_name:=> { version:=> { date:=>download_times } } }
class GemMiner

	# initialize the class with the gem_name
	def initialize(gem_name)
		@gem_name = gem_name
	end

	# scan gem name


	# call the method to get what needed in a hash format
	def get_versions
		hash=Hash.new{|h,k| h[k] = Hash.new(&h.default_proc)}
		vers = Gems.versions @gem_name
		vers.each do |ver|
			downloads=Gems.downloads @gem_name, ver["number"]
			downloads.each do |k,v|
				hash[@gem_name.to_s][ver["number"]][k] = v
			end
		end
		return hash
	end

	# call the method to get the updating downloads time ( yesterday )
	def get_yesterday_downloads
		hash=Hash.new{|h,k| h[k] = Hash.new(&h.default_proc)}
		vers = Gems.versions @gem_name
		vers.each do |ver|
			downloads = Gems.downloads @gem_name, ver["number"], Date.today-1, Date.today-1
			downloads.each do |k,v|
				hash[@gem_name][ver["number"]][k] = v
			end
		end
		return hash
	end
end


