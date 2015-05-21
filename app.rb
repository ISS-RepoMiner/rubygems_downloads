require 'sinatra'
require 'httparty'
require 'json'
require 'config_env'
require_relative 'lib/gem_map_queue'
require_relative 'lib/gem_worker'

module GemMiner
  # Web Service that takes SNS notifications
  class MiningService < Sinatra::Base
    configure :development, :test do
      ConfigEnv.path_to_config("#{__dir__}/config/config_env.rb")
    end

    configure :production, :development do
      # set :gem_queue, GemMapQueue.new(ENV['SQS_GEM_QUEUE'])
      enable :logging
    end

    get '/' do
      'GemMiner up and working<br> POST messages to /notification'
    end

    def mine_gems_from_queue(queue_name=nil)
      WorkerPool.new(queue_name).perform_async
    end

    def handle_notification(&_handler)
      logger.info 'MESSAGE ARRIVING'
      sns_msg_type = request.env['HTTP_X_AMZ_SNS_MESSAGE_TYPE']
      sns_note = JSON.parse request.body.read

      topic_arn = sns_note['TopicArn']
      if topic_arn != ENV['WakeupTopicArn']
        logger.info "UNAUTHORIZED ACCESS (ARN): #{topic_arn}"
        halt 403, 'Unauthorized Topic ARN'
      end

      case sns_msg_type
      when 'SubscriptionConfirmation'
        sns_confirm_url = sns_note['SubscribeURL']
        sns_confirmation = HTTParty.get sns_confirm_url
        logger.info "SUBSCRIBE REQUEST: URL: [#{sns_confirm_url}], Confirm: [#{sns_confirmation}]"
        halt 403, 'Invalid SubscribeURL' unless sns_confirmation.code == 200
      when 'Notification'
        logger.info "WORK REQUEST: Subject: [#{sns_note['Subject']}], Body: [#{sns_note['Message']}]"
        yield sns_note['Message']
      else
        fail "Invalid SNS Message Type (#{sns_msg_type})"
      end

      status 200
    rescue => e
      logger.error e
      halt 400, 'Could not fully process message'
    end

    # Listen to SNS for subscription request or message notifications
    post '/notification' do
      handle_notification do |msg|
        message = JSON.parse(msg)
        queue_name = message['QueueName']
        if (queue_name.nil? or queue_name.empty?)
          logger.info "QueueName for job not specified"
        else
          mine_gems_from_queue(queue_name)
        end
      end
    end
  end
end
