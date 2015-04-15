require_relative 'spec_helper'

dropbox = GemVersionDownload.new
dropbox.add_put('dropbox-api', '0.4.6', Date.today.to_s, 213, 4)
citesight = GemVersionDownload.new
citesight.add_put('citesight', '0.1.0', Date.today.to_s, 12, 3)

db = NoSqlStore.new(db_client:'test')
db.add_for_batch(dropbox)
db.add_for_batch(citesight)

batch_items = {
  "GemVersionDownload" => [
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

describe 'Add a batch of put items' do
  it 'should make an accurate batch of put items' do
    db.request_items.must_equal batch_items
  end
end
