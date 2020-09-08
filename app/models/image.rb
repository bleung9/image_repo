require 'elasticsearch/model'

class Image < ApplicationRecord
  include Elasticsearch::Model
  include Elasticsearch::Model::Callbacks

  mount_uploader :image, ImageUploader

  validates_presence_of :image

  index_name "images-#{Rails.env}"

  settings do
    mappings dynamic: 'false' do
      indexes :text, type: :text, analyzer: 'english'
    end
  end

  DISTANCE_THRESHOLD = 25

  def self.search_text(query)
    Image.search(query)
  end

  def self.open_image(file)
    MiniMagick::Image.open(file)
  end

  def self.run_ocr(file)
    RTesseract.new(file)
  end

  def self.run_idhash(file)
    DHashVips::IDHash.fingerprint(file) if file.present?
  end

  def self.similar_images?(hash1, hash2)
    DHashVips::IDHash.distance(hash1, hash2) < DISTANCE_THRESHOLD
  end
end



