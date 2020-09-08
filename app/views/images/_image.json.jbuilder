json.extract! image, :id, :image, :width, :height, :created_at, :updated_at
json.url image_url(image, format: :json)
