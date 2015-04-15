# Generic Store for DynamoDB
class NoSqlStore
  attr_reader :request_items

  def initialize(db_client:nil)
    @request_items = {}
    @dynamodb = db_client || Aws::DynamoDB::Client.new
    @mutex = Mutex.new
  end

  def add_for_batch(record)
    @mutex.synchronize do
      @request_items[record.table] ||= []
      @request_items[record.table] << { put_request: { item: record.put_items } }
      self
    end
  end

  def put_batch
    #resp = dynamodb.batch_write_item(request_items: @request_items)
    puts({ request_items: @request_items })
  end

  def self.put_single(record)
    @dynamodb.put_item(table_name: record.table, item: record.items)
  end

  def batch_save
    request_items = {}
    @records.each

    resp = dynamodb.batch_write_item(
      request_items: {
        "gem_daily_downloads" => [
          {
            put_request: {
              item: {
                'name_version' => 'dropbox-api[0.4.6]',
                'date' => Date.today.to_s,
                'download_total' => { value: 213 },
                'download_today' => { value: 4 }
              }
            }
          },
          {
            put_request: {
              item: {
                'name_version' => 'citesight[0.1.0]',
                'date' => Date.today.to_s,
                'download_total' => { value: 12 },
                'download_today' => { value: 3 }
              }
            }
          }
        ]
      }
    )
  end
end
