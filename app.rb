require "./GemMiner.rb"
require "ftools"

gem_names=File.open("gem_list.txt").readlines.each do |x| x.strip! end


all_dictionary=Hash.new{|h,k| h[k] = Hash.new(&h.default_proc)}



gem_names[1..10].each do |gem_name| 
	puts gem_name 
	file=File.open("./downloads/"+gem_name+".txt","w")
	gem_downloads = GemMiner.new gem_name
	file.puts gem_downloads.get_versions_downloads_list
end


# a=GemMiner.new "movie_crawler"
# # puts a.get_vers_list
# puts a.get_versions_downloads_list
# # hash=a.get_versions
# puts a.get_yesterday_downloads


# begin

# rescue

# end


# all_hash.merge!(hash)

# puts all_hash



			# File.open("test", "a") do |aFile|
			# 	result = @gem_name+ver["number"]+downloads.to_s
			# 	aFile.syswrite(result)
			# end