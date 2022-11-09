class Logo < ApplicationRecord
    include LogosHelper
    require 'chunky_png'

    has_one_attached :image
    has_one_attached :image_converted
    has_one_attached :posterized_image
    has_one_attached :posterized_image_converted

    has_many_attached :converted_images

    validates :name, presence: true
    validates :posterization_level, presence: true

    def unique_colors_count(image)
        @image = MiniMagick::Image.open(ActiveStorage::Blob.service.send(:path_for, image.key))
        pixels = @image.get_pixels
        unique_colors = {}
        pixels.each{ |row| row.each{ |pixel| unique_colors[pixel] = pixel unless unique_colors.key?(pixel) } }
        color_count = unique_colors.keys.count  
        return color_count
    end 
end
