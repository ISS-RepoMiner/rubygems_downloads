require 'aws-sdk'

module GemMiner
  class GemMapQueue
    attr_writer :logger

    def initialize(queue_name, logger = nil)
      @sqs = Aws::SQS::Client.new(region: ENV['AWS_REGION'])
      @queue_url = @sqs.get_queue_url(queue_name: queue_name).queue_url
      @logger = logger
    rescue => e
      log_error(e, 'Could not connect to queue')
    end

    def log_error(ex, description)
      if @logger
        err = ex.is_a?(Aws::SQS::Errors::ServiceError) ? 'QUEUE_ERROR' : 'ERROR'
        @logger.error("#{err}: #{description}")
      else
        puts description
      end
      fail ex
    end

    def messages_available
      attrs = @sqs.get_queue_attributes(
        queue_url: @queue_url,
        attribute_names: ['ApproximateNumberOfMessages']
      )
      attrs.attributes['ApproximateNumberOfMessages'].to_i
    rescue => e
      log_error(e, 'Could not get number of messages from queue')
    end

    def poll(batch_size, &message_handler)
      poller = Aws::SQS::QueuePoller.new(@queue_url)
      poller.poll(max_number_of_messages: batch_size,
                  wait_time_seconds: 0,
                  idle_timeout: 5) do |msg|
        yield msg.body
      end
    rescue => e
      log_error(e, 'Failed while polling queue')
    end

    def poll_batch(batch_size = 10, &_message_handler)
      poller = Aws::SQS::QueuePoller.new(@queue_url)
      poller.poll(max_number_of_messages: batch_size,
                  wait_time_seconds: 0,
                  idle_timeout: 5) do |msgs|
        yield msgs.map(&:body)
      end
    rescue => e
      log_error(e, 'Failed while polling queue')
    end
  end
end

## Sample code
# q = GemMiner::GemMapQueue.new('GemMap')
#
# q.messages_available
#
# q.poll do |msg|
#  puts "MSG: #{msg}"
# end
#
# q.poll_batch(batch_size = 10) do |msg|
#  puts "MSG: #{msg}"
# end
#
#
# letters = ('a'..'z').take(26)
#
# 100.times.map do |i|
#   body = letters.sample(10).join
#   sqs.send_message(queue_url: queue_url, message_body: body)
#   print "#{i} "
# end
