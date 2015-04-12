require "./GemMiner.rb"
require "ftools"

# read the gem list
gem_names=File.open("gem_list.txt").readlines.each do |x| x.strip! end



# all_dictionary=Hash.new{|h,k| h[k] = Hash.new(&h.default_proc)}


# crawling the downloads accumulated and save them in unique file
gem_names[1..10].each do |gem_name| 
	puts gem_name 
	begin
		file=File.open("./downloads/"+gem_name+".txt","w")
		gem_downloads = GemMiner.new gem_name
		file.puts gem_downloads.get_versions_downloads_list
	rescue
		file=File.open("error_gems.txt","a")
		file.puts gem_name
	end
end


# a=GemMiner.new "movie_crawler"
# # puts a.get_vers_list
# puts a.get_versions_downloads_list
# # hash=a.get_versions
# puts a.get_yesterday_downloads

