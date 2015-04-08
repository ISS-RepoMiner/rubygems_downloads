require 'sinatra'
require 'httparty'
require 'json'
require 'config_env'
require './pull-queue'

class GemMinerService < Sinatra::Base
  configure :production, :development do
    enable :logging
  end

  configure :development, :test do
    ConfigEnv.path_to_config("#{__dir__}/config/config_env.rb")
  end

  configure do
    set :gem_queue, GemMinerQueue.new(ENV['SQS_GEM_QUEUE'], logger)
  end

  get '/' do
    'GemMiner up and working<br> POST messages to /notification'
  end

  # Listen to SNS for subscription request or message notifications
  post '/notification' do
    begin
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
        # TODO: handle wakeup message
        logger.info "MESSAGE: Subject: [#{sns_note['Subject']}], Body: [#{sns_note['Message']}]"
      else
        fail "Invalid SNS Message Type (#{sns_msg_type})"
      end
    rescue => e
      logger.error e
      halt 400, 'Could not fully process SNS notification'
      return
    end

    status 200
  end
end
