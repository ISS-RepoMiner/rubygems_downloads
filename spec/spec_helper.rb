ENV['RACK_ENV'] = 'test'

require 'minitest/autorun'
require 'rack/test'
require 'webmock/minitest'


require_relative '../gem_miner_service'

include Rack::Test::Methods

def app
  GemMiner::MiningService
end
