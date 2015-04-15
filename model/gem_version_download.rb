# Model of daily downloads table
class GemVersionDownload
  Key = Struct.new(:name, :type)
  attr_reader :table
  attr_reader :hash_key
  attr_reader :range_key
  attr_reader :non_key_items

  attr_reader :items

  def initialize
    @table = self.class.name
    @hash_key = Key.new('name_version', String)
    @range_key = Key.new('date', String)
    @non_key_items = ['download_total', 'download_today']
    @items = {}
  end

  def add_put(gem_name, version, date, *items)
    @items = {
      @hash_key.name => "#{gem_name}[#{version}]",
      @range_key.name => date
    }
    items.each.with_index do |value, i|
      @items[@non_key_items[i]] = { value: value }
    end
  end
end
