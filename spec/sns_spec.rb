require_relative 'spec_helper'

describe 'SNS Message Notification' do
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

  describe 'SNS Subscription Request' do
    it 'should return 403 for invalid confirmation URL' do
      header = { 'CONTENT_TYPE' => 'text/html',
                 'HTTP_X_AMZ_SNS_MESSAGE_TYPE' => 'SubscriptionConfirmation'}
      body = {
        'TopicArn' => ENV['WakeupTopicArn'],
        'Token' => '897432234978234978423987',
        'SubscribeURL' => "https://foo.bar"
      }

      stub_request(:get, "https://foo.bar").
        to_return(:body => "foo", :status => 400,
          :headers => { 'Content-Length' => 3 })

      post '/notification', body.to_json, header

      last_response.status.must_equal 403
    end

    it 'should return 403 for unaccepted AWS confirmation URL' do
      bad_url = 'https://sns.us-west-2.amazonaws.com/?Action=ConfirmSubscription&TopicArn=arn:aws:sns:us-west-2:123456789012:MyTopic&Token=897432234978234978423987'
      header = { 'CONTENT_TYPE' => 'text/html',
                 'HTTP_X_AMZ_SNS_MESSAGE_TYPE' => 'SubscriptionConfirmation'}
      body = {
        'TopicArn' => ENV['WakeupTopicArn'],
        'Token' => '897432234978234978423987',
        'SubscribeURL' => bad_url
      }

      stub_request(:get, bad_url).
        to_return(:body => "foo", :status => 400,
          :headers => { 'Content-Length' => 3 })

      post '/notification', body.to_json, header

      last_response.status.must_equal 403
    end

    it 'should return ok for valid confirmation request' do
      good_url = 'https://sns.us-west-2.amazonaws.com/?Action=ConfirmSubscription&TopicArn=arn:aws:sns:us-west-2:123456789012:MyTopic&Token=897432234978234978423987'
      header = { 'CONTENT_TYPE' => 'text/html',
                 'HTTP_X_AMZ_SNS_MESSAGE_TYPE' => 'SubscriptionConfirmation'}
      body = {
        'TopicArn' => ENV['WakeupTopicArn'],
        'Token' => '897432234978234978423987',
        'SubscribeURL' => good_url
      }

      stub_request(:get, good_url).
        to_return(:body => "foo", :status => 200,
          :headers => { 'Content-Length' => 3 })

      post '/notification', body.to_json, header

      last_response.status.must_equal 200
    end
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
