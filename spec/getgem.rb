#!/usr/bin/env ruby
require_relative '../lib/GemMiner.rb'
require 'json'

fail ArgumentError, "Usage:  getgem [gemname]\n" if ARGV.count != 1
gem_name = ARGV[0]
gem_filename = File.join(File.dirname(__FILE__), "/testfiles/#{gem_name}.txt")

begin
  dropbox = GemMiner.new('dropbox-api')
  dropbox_downloads = dropbox.get_versions_downloads_list
rescue => e
  puts e
  puts 'Could not find gem information from Rubygems\n' \
       ' check gem name and Internet connection'
  exit
end

dropbox_file = File.open(gem_filename, 'w')
dropbox_file.write(dropbox_downloads.to_json)
