
# Testing code for multiple dates search
require_relative './lib/GemMiner'
dropbox = GemMiner::Node.new('dropboxapi', '2015-03-17', '2015-03-18')
dp = GemMiner::Miner.new(dropbox);
dp.get_yesterday_downloads_cachedpool
