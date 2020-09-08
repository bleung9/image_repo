class ImagesController < ApplicationController
  include CarrierWave::MiniMagick

  before_action :set_image, only: [:show]

  def index
    search_params = { 
      extension: params[:search_format]&.upcase&.strip,
      width: params[:search_width]&.strip,
      height: params[:search_height]&.strip,
      id: (Image.search_text(params[:search_text]).records.pluck(:id) unless params[:search_text].blank?)
    }.reject { |k, v| v.blank? }

    @images = search_params.empty? ? Image.all : Image.where(search_params)
  end

  def show
  end

  def get_similar_images
    hash = DHashVips::IDHash.fingerprint(params[:image].path)
    ids = Image.all.to_a.filter { |image| DHashVips::IDHash.distance(hash, image.idhash.to_i) < 25 }.map(&:id)
    @images = Image.find(ids)
  end

  def new
    @image = Image.new
  end

  def create
    @image = Image.new(image_params)

    respond_to do |format|
      if @image.save
        path = @image.image.file.file
        current_image = @image.open_image(path)
        ocr = @image.run_ocr(path)
        idhash = @image.run_idhash(path)

        @image.update(
          width: current_image[:width],
          height: current_image[:height],
          extension: current_image[:format],
          text: ocr.to_s.split("\n").join(" ").delete("\f"),
          idhash: idhash.to_s
        )

        format.html { redirect_to @image, notice: 'Image was successfully created.' }
        format.json { render :show, status: :created, location: @image }
      else
        format.html { render :new }
        format.json { render json: @image.errors, status: :unprocessable_entity }
      end
    end
  end

  private
    def set_image
      @image = Image.find(params[:id])
    end

    def image_params
      params.require(:image).permit(:image)
    end
end
