require 'config_env'
require 'aws-sdk'

ConfigEnv.path_to_config("#{__dir__}/config/config_env.rb")

dynamodb = Aws::DynamoDB::Client.new

resp = dynamodb.put_item(
  table_name: 'gem_daily_downloads',
  item: {
    'name_version' => 'dropbox-api[0.4.6]',
    'date' => Date.today.to_s,
    'download_total' => { value: 213 },
    'download_today' => { value: 4 }
  }
)
