class ImagesController < ApplicationController
  include CarrierWave::MiniMagick

  before_action :set_image, only: [:show]

  def index
    ids = Image.search_text(params[:search_text]).records.pluck(:id) unless params[:search_text].blank?
    search_params = { 
      extension: params[:search_format]&.upcase&.strip,
      width: params[:search_width]&.strip,
      height: params[:search_height]&.strip,
      id: ids
    }.reject { |k, v| v.blank? }
    
    if params[:search_text].present? && ids.blank?
      @images = []
    elsif params[:search_text].present? || search_params.present?
      @images = Image.where(search_params)
    else
      @images = Image.all
    end
  end

  def show
  end

  def get_similar_images
    hash = Image.run_idhash(params[:image]&.path)
    ids = Image.all.to_a.filter { |image| Image.similar_images?(hash, image.idhash.to_i) }.map(&:id)
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
        current_image = Image.open_image(path)
        ocr = Image.run_ocr(path)
        idhash = Image.run_idhash(path)

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
