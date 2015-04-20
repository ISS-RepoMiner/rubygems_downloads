require './app'

def mine_gem(gem_name)
  jem = GemMiner::Node.new(gem_name, '2015-03-17', '2015-03-18')
  dp = GemMiner::Miner.new(jem);
  dp.get_yesterday_downloads_cachedpool
end

def save_nugget(nugget)
  db = NoSqlStore.new
end
