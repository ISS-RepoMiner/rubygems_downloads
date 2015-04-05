require 'sinatra'
require 'json'

class GemMinerService < Sinatra::Base
  get '/' do
    'GemMiner up and working'
  end

  # Listen to SNS for subscription request or message notifications
  post '/notification' do
    begin
      sns_msg_type = request.env["HTTP_X_AMZ_SNS_MESSAGE_TYPE"]
      sns_note = JSON.parse request.body.read

      case sns_msg_type
      when 'SubscriptionConfirmation'
        sns_confirm_url = sns_note['SubscribeURL']
        sns_confirmation = HTTParty.get sns_confirm_url
      when 'Notification'
        save_message sns_note['Subject'], sns_note['Message']
      end
    rescue => e
      logger.error e
      halt 400, "Could not fully process SNS notification"
      return
    end

    status 200
  end
end
