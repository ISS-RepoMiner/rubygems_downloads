require 'sinatra'
require 'httparty'
require 'json'
require 'config_env'
require_relative 'lib/gem_map_queue'
require_relative 'lib/no_sql_store'
require_relative 'model/gem_version_download'

module GemMiner
  class MiningService < Sinatra::Base
    configure :development, :test do
      ConfigEnv.path_to_config("#{__dir__}/config/config_env.rb")
    end

    configure :production, :development do
      set :gem_queue, GemMapQueue.new(ENV['SQS_GEM_QUEUE'])
      enable :logging
    end

    configure :test do
      set :gem_queue, GemMapQueue.new
    end

    before do
      settings.gem_queue.logger = logger
    end

    get '/' do
      'GemMiner up and working<br> POST messages to /notification'
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
        logger.info "SUBSCRIBE: URL: [#{sns_confirm_url}], Confirm: [#{sns_confirmation}]"
        halt 403, 'Invalid SubscribeURL' unless sns_confirmation.code == 200
      when 'Notification'
        logger.info "MESSAGE: Subject: [#{sns_note['Subject']}], Body: [#{sns_note['Message']}]"
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
        # TODO: handle notification here (example in next 5 lines)
        # puts "#{settings.gem_queue.messages_available} gems found"
        settings.gem_queue.poll_batch(batch_size=10) do |gems_map|
          # TODO: handle gems here (example in next line)
          # puts "Gems: #{gems_map}"
        end
      end
    end
  end
end
