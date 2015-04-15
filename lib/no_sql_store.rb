require 'aws-sdk'

# Generic Store for DynamoDB
class NoSqlStore
  attr_reader :request_items

  def initialize
    @request_items = {}
    @mutex = Mutex.new
    @db = Aws::DynamoDB::Client.new
  end

  def add_to_batch(record)
    @mutex.synchronize do
      @request_items[record.table] ||= []
      @request_items[record.table] << { put_request: { item: record.put_items } }
      self
    end
  end

  def self.put_single(record)
    @db.put_item(table_name: record.table, item: record.items)
  end

  def batch_save
    resp = @db.batch_write_item(request_items: @request_items)
    # puts({ request_items: @request_items })
  end

  def create_table(model, read_capacity, write_capacity)
    params = {
      attribute_definitions: [
        { attribute_name: 'name_version', attribute_type: 'S' },
        { attribute_name: 'date', attribute_type: 'S' }
      ],
      table_name: model.name,
      key_schema: [
        { attribute_name: 'name_version', key_type: 'HASH' },
        { attribute_name: 'date', key_type: 'RANGE' }
      ],
      provisioned_throughput: {
        read_capacity_units: read_capacity,
        write_capacity_units: write_capacity
      }
    }
    @db.create_table(params)
    self
  end
end
