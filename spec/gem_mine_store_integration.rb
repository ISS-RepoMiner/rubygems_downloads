require './app'

def mine_gem_for_node(gem_name)
  jem = GemMiner::Node.new(gem_name, '2015-03-17', '2015-03-18')
  dp = GemMiner::Miner.new(jem);
  dp.get_yesterday_downloads_cachedpool.node
end

def save_node(node)
  db = NoSqlStore.new
  
end
