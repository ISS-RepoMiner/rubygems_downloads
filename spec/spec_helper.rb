ENV['RACK_ENV'] = 'test'

require 'minitest/autorun'
require 'rack/test'
require_relative '../gem_miner_service'

include Rack::Test::Methods

def app
  GemMinerService
end
