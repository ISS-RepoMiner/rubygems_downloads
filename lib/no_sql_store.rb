require 'aws-sdk'

# Generic Store for DynamoDB
class NoSqlStore < Aws::DynamoDB::Client
  attr_reader :request_items

  def initialize(*args)
    super
    @request_items = {}
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
    put_item(table_name: record.table, item: record.items)
  end

  def batch_save
    resp = batch_write_item(request_items: @request_items)
  end

  def create_new_table(model, read_throughput, write_throughput)
    params = {
      attribute_definitions: [
        {
          attribute_name: 'name_version',
          attribute_type: 'S'
        },
        {
          attribute_name: 'date',
          attribute_type: 'S'
        },
        {
          attribute_name: 'downloads_total',
          attribute_type: 'S'
        },
        {
          attribute_name: 'downloads_today',
          attribute_type: 'S'
        }
      ],
      table_name: model.name
    }
    create_table(params)
  end
end
