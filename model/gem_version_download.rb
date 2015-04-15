# Model of daily downloads table
class GemVersionDownload
  attr_reader :table
  attr_reader :put_items

  def initialize
    @table = self.class.name
  end

  def add_put(gem_name, version, date, dl_total, dl_today)
    @put_items = {
      'name_version' => "#{gem_name}[#{version}]",
      'date' => date,
      'download_total' => { value: dl_total },
      'download_today' => { value: dl_today }
    }
  end
end
