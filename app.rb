require "./GemMiner.rb"

all_hash=Hash.new{|h,k| h[k] = Hash.new(&h.default_proc)}

a=GemMiner.new "rails"

# hash=a.get_versions
hash=a.get_yesterday_downloads

all_hash.merge!(hash)

puts all_hash



			# File.open("test", "a") do |aFile|
			# 	result = @gem_name+ver["number"]+downloads.to_s
			# 	aFile.syswrite(result)
			# end