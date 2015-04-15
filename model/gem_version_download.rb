# Model of daily downloads table
class GemVersionDownload
  attr_reader :table
  attr_reader :put_items
  Key = Struct.new(:name, :type)

  attr_reader :hash_key
  attr_reader :range_key
  attr_reader :items

  def initialize
    @table = self.class.name
    @hash_key = Key.new('name_version', String)
    @range_key = Key.new('date', String)
    @items = ['download_total', 'download_today']
  end

  def add_put(gem_name, version, date, *items)
    @put_items = {
      @hash_key.name => "#{gem_name}[#{version}]",
      @range_key.name => date
    }
    items.each.with_index do |value, i|
      @put_items[@items[i]] = { value: value }
    end
  end
end
