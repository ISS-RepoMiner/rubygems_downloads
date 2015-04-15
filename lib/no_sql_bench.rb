require 'benchmark'
require_relative '../app.rb'

dropbox = GemVersionDownload.new
dropbox.add_put('dropbox-api', '0.4.6', Date.today.to_s, 213, 4)
citesight = GemVersionDownload.new
citesight.add_put('citesight', '0.1.0', Date.today.to_s, 12, 3)

db = NoSqlStore.new
db.add_to_batch(dropbox)
db.add_to_batch(citesight)
