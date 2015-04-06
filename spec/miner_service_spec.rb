require_relative 'spec_helper'

describe 'GemMinerService specifications' do
  it 'should return ok for the root route' do
    get '/'
    last_response.must_be :ok?
  end
end
