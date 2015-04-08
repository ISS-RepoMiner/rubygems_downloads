require_relative 'spec_helper'

describe 'GemMinerService specifications' do
  it 'should return ok for the root route' do
    get '/'
    last_response.must_be :ok?
  end

  it 'should return 200 for Notification message type' do
    header = { 'CONTENT_TYPE' => 'text/html',
               'HTTP_X_AMZ_SNS_MESSAGE_TYPE' => 'Notification'}
    body = {
      'TopicArn' => ENV['WakeupTopicArn']
    }

    FakeQueue = Class.new do
      attr_writer :logger

      def messages_available
        10
      end

      def poll_batch(&_message_handler)
        gem_name = ('a'..'z').take(26).sample(7).join
        yield gem_name
      end

      def poll_batch(batch_size = 10, &_message_handler)
        letters = ('a'..'z').take(26)

        Random.rand(2..5).times do
          gems_map = Random.rand(1..batch_size).times.map do |i|
            letters.sample(7).join
          end

          yield gems_map
        end
      end
    end

    app.settings.gem_queue = FakeQueue.new

    post '/notification', body.to_json, header
    last_response.status.must_equal 200

  end
end
