require 'rails_helper'

RSpec.describe "Images", type: :request do
  after(:all) do
    Image.__elasticsearch__.client.indices.delete(index: Image.index_name)
  end

  describe "GET /new" do
    it "renders a successful response" do
      get new_image_url

      expect(response).to be_successful
    end
  end

  describe "POST /create" do
    before(:all) do
      Image.__elasticsearch__.create_index!(force: true)
    end

    before do
      image = fixture_file_upload('images/image_with_text_1.jpg')
      post images_url, params: { image: { image: image } }
      Image.__elasticsearch__.refresh_index!
    end

    it "creates a new image" do
      expect(Image.count).to eq(1)
    end

    it "indexes it in Elasticsearch" do
      response = Image.search_text("class")

      expect(response.count).to eq(1)
      expect(response.records.first.image.file.filename).to eq("image_with_text_1.jpg")
    end
  end

  describe "GET /index" do
    before(:all) do
      Image.__elasticsearch__.create_index!(force: true)
    end

    before do
      image_files = Dir.glob("#{Rails.root}/spec/fixtures/images/*")
      image_files.each do |file|
        image = fixture_file_upload(file)
        post images_url, params: { image: { image: image } }
      end
      Image.__elasticsearch__.refresh_index!
    end
    
    it "returns three images with no filter parameters" do
      get images_url

      expect(assigns(:images).count).to eq(5)
    end

    it "returns one image with width 1125" do
      get images_url, params: { search_width: 1125 }

      expect(assigns(:images).count).to eq(1)
      expect(assigns(:images).first.image.file.filename).to eq("image_with_text_2.jpg")
    end

    it "returns one image with height 1232" do
      get images_url, params: { search_height: 1232 }

      expect(assigns(:images).count).to eq(1)
      expect(assigns(:images).first.image.file.filename).to eq("surprised_pikachu.png")
    end

    it "returns no images with height 1337" do
      get images_url, params: { search_height: 1337 }

      expect(assigns(:images).count).to eq(0)
    end

    it "returns no images with width 1337 and height 1520" do
      get images_url, params: { search_width: 1337, search_height: 1520 }

      expect(assigns(:images).count).to eq(0)
    end

    it "returns one image with width 1520 and height 1232" do
      get images_url, params: { search_width: 1520, search_height: 1232 }

      expect(assigns(:images).count).to eq(1)
      expect(assigns(:images).first.image.file.filename).to eq("surprised_pikachu.png")
    end

    it "returns two images with format PNG" do
      get images_url, params: { search_format: "png" }
      expect(assigns(:images).count).to eq(2)

      images = assigns(:images).pluck(:image).sort
      expect(images == ["sky_1.png", "surprised_pikachu.png"]).to eq(true)
    end

    it "returns no image with text search 'asdfasdf'" do
      get images_url, params: { search_text: "asdfasdf" }

      expect(assigns(:images).count).to eq(0)
    end

    it "returns one image with text search 'zoom'" do
      get images_url, params: { search_text: "zoom" }

      expect(assigns(:images).count).to eq(1)
      expect(assigns(:images).first.image.file.filename).to eq("image_with_text_3.jpg")
    end

    it "returns one image with width 1125 and text search 'class'" do
      get images_url, params: { search_width: 1125, search_text: "class" }

      expect(assigns(:images).count).to eq(1)
      expect(assigns(:images).first.image.file.filename).to eq("image_with_text_2.jpg")
    end

    it "returns three images with text search 'class'" do
      get images_url, params: { search_text: "class" }

      expect(assigns(:images).count).to eq(3)

      images = assigns(:images).pluck(:image).sort
      expect(images == ["image_with_text_1.jpg", "image_with_text_2.jpg", "image_with_text_3.jpg"]).to eq(true)
    end

    it "returns two images with text search 'and class'" do
      get images_url, params: { search_text: "and class" }
      expect(assigns(:images).count).to eq(3)

      images = assigns(:images).pluck(:image).sort
      expect(images == ["image_with_text_1.jpg", "image_with_text_2.jpg", "image_with_text_3.jpg"]).to eq(true)
    end

    it "returns two images with text search 'funny information'" do
      get images_url, params: { search_text: "funny information" }
      expect(assigns(:images).count).to eq(2)
      
      images = assigns(:images).pluck(:image).sort
      expect(images == ["image_with_text_1.jpg", "image_with_text_2.jpg"]).to eq(true)
    end
  end

  describe "POST /get_similar_images" do
    before(:all) do
      Image.__elasticsearch__.create_index!(force: true)
    end

    before do
      image_files = Dir.glob("#{Rails.root}/spec/fixtures/images/*")
      image_files.each do |file|
        image = fixture_file_upload(file)
        post images_url, params: { image: { image: image } }
      end
      Image.__elasticsearch__.refresh_index!
    end

    it "returns no similar images when submitting a dissimilar image" do
      image = fixture_file_upload('similar_image_test/federer.png')
      post similar_images_url, params: { image: image }

      expect(assigns(:images).count).to eq(0)
    end

    it "returns one similar image when submitting a similar image" do
      image = fixture_file_upload('similar_image_test/sky_2.png')
      post similar_images_url, params: { image: image }

      expect(assigns(:images).count).to eq(1)
      expect(assigns(:images).first.image.file.filename).to eq("sky_1.png")
    end

  end
end