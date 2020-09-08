require 'elasticsearch/model'

class Image < ApplicationRecord
  include Elasticsearch::Model
  include Elasticsearch::Model::Callbacks

  mount_uploader :image, ImageUploader

  index_name "images-#{Rails.env}"

  settings do
    mappings dynamic: 'false' do
      indexes :text, type: :text, analyzer: 'english'
    end
  end

  def self.search_text(query)
    Image.search(query)
  end

  def open_image(file)
    MiniMagick::Image.open(file)
  end

  def run_ocr(file)
    RTesseract.new(file)
  end

  def run_idhash(file)
    DHashVips::IDHash.fingerprint(file)
  end
end



