require_relative "GemMiner"

gem_map = ['retailigence', 'localizer', 'roopap', 'jekyll-minifier', 'vagrant-parallels', 'phidgets-ffi', 'dropbox-api']

gem_map = ['dropbox-api']
def get_gem_downloads(gem_map)
  downloads = gem_map.map do |gem_name|
    rubygem = GemMiner.new(gem_name)
    rubygem.get_info
    yesterday = rubygem.get_yesterday_downloads
    non_zero_dl = yesterday[gem_name].select { |ver, dls| dls.first[1] > 0 }
    {gem_name => non_zero_dl}
  end
end

# require "ftools"
#
# # read the gem list
# gem_names=File.open("gem_list.txt").readlines.each do |x| x.strip! end
#
#
#
# # all_dictionary=Hash.new{|h,k| h[k] = Hash.new(&h.default_proc)}
#
#
# # crawling the downloads accumulated and save them in unique file
# gem_names[1..10].each do |gem_name|
#   puts gem_name
#   begin
#     file=File.open("./downloads/"+gem_name+".txt","w")
#     gem_downloads = GemMiner.new gem_name
#     file.puts gem_downloads.get_versions_downloads_list
#   rescue
#     file=File.open("error_gems.txt","a")
#     file.puts gem_name
#   end
# end
