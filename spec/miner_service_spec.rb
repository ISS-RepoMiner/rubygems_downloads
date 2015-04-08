require_relative 'spec_helper'

describe 'GemMinerService specifications' do
  it 'should return ok for the root route' do
    get '/'
    last_response.must_be :ok?
  end

  it 'should return 200 for Notification message type' do
    header = { 'CONTENT_TYPE' => 'text/html',
               'HTTP_X_AMZ_SNS_MESSAGE_TYPE' => 'Notification' }
    body = {
      'TopicArn' => ENV['WakeupTopicArn']
    }

    FakeQueue = Class.new do
      attr_writer :logger

      def initialize
        letters = ('a'..'z').take(26)

        @gems_map_arr = Random.rand(2..5).times.map do
          Random.rand(1..10).times.map do
            letters.sample(7).join
          end
        end
      end

      def messages_available
        @gems_map_arr.reduce(0) { |a, e| a + e.length }
      end

      def poll(&_message_handler)
        @gems_map_arr.flatten!.length.times { yield @gems_map_arr.shift }
      end

      def poll_batch(_batch_size = 10, &_message_handler)
        @gems_map_arr.length.times { yield @gems_map_arr.shift }
      end
    end

    app.settings.gem_queue = FakeQueue.new

    post '/notification', body.to_json, header
    last_response.status.must_equal 200
  end
end
