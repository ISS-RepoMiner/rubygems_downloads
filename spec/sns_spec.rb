require_relative 'spec_helper'

describe 'SNS Subscription' do
  it 'should return 403 for wrong TopicARN' do
    header = { 'CONTENT_TYPE' => 'text/html' }
    body = {
      'TopicArn' => 'arn:aws:sns:us-west-2:123456789012:WrongTopic'
    }

    post '/notification', body.to_json, header

    last_response.status.must_equal 403
  end

  it 'should return 200 for Notification message type' do
    header = { 'CONTENT_TYPE' => 'text/html',
               'HTTP_X_AMZ_SNS_MESSAGE_TYPE' => 'Notification'}
    body = {
      'TopicArn' => ENV['WakeupTopicArn']
    }

    post '/notification', body.to_json, header

    last_response.status.must_equal 200
  end

  it 'should return 200 for SubscriptionConfirmation message type' do
    header = { 'CONTENT_TYPE' => 'text/html',
               'HTTP_X_AMZ_SNS_MESSAGE_TYPE' => 'SubscriptionConfirmation'}
    body = {
      'TopicArn' => ENV['WakeupTopicArn']
    }

    post '/notification', body.to_json, header

    # TODO: stub and test SubscriptionConfirmation message
    last_response.status.must_equal 200
  end

  it 'should return 400 for unknown message type' do
    header = { 'CONTENT_TYPE' => 'text/html',
               'HTTP_X_AMZ_SNS_MESSAGE_TYPE' => 'UnknownType'}
    body = {
      'Type' => 'Check invalid users and invalid badges',
      'TopicArn' => ENV['WakeupTopicArn']
    }

    post '/notification', body.to_json, header

    last_response.status.must_equal 400
  end
end
