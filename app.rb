
all_hash=Hash.new{|h,k| h[k] = Hash.new(&h.default_proc)}

a=Gems_downloads.new "ltp_checker"

hash=a.get_versions

all_hash.merge!(hash)

puts all_hash