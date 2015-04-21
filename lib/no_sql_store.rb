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
      @request_items[record.table] << { put_request: { item: record.items } }
      self
    end
  end

  def save(record)
    @db.put_item(table_name: record.table, item: record.items)
  end

  def batch_save
    resp = @db.batch_write_item(request_items: @request_items)
    @mutex.synchronize do
      @request_items = {}
    end
    resp
    # puts({ request_items: @request_items })
  end

  def create_table(model, read_capacity, write_capacity)
    prototype = model.new
    hash_key = prototype.hash_key
    range_key = prototype.range_key
    type = { String => 'S', Fixnum => 'N' }

    params = {
      attribute_definitions: [
        { attribute_name: hash_key.name, attribute_type: type[hash_key.type] },
        { attribute_name: range_key.name, attribute_type: type[range_key.type] }
      ],
      table_name: prototype.table,
      key_schema: [
        { attribute_name: prototype.hash_key.name, key_type: 'HASH' },
        { attribute_name: prototype.range_key.name, key_type: 'RANGE' }
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
