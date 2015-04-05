require "./GemMiner.rb"

all_hash=Hash.new{|h,k| h[k] = Hash.new(&h.default_proc)}

a=GemMiner.new "movie_crawler"
# puts a.get_vers_list
puts a.get_versions_downloads_list
# hash=a.get_versions
puts a.get_yesterday_downloads

# all_hash.merge!(hash)

# puts all_hash



			# File.open("test", "a") do |aFile|
			# 	result = @gem_name+ver["number"]+downloads.to_s
			# 	aFile.syswrite(result)
			# end