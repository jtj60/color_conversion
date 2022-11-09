class LogoConverter
  include LogosHelper
  require 'rmagick'

  def initialize(logo)
    @logo = logo
    @image_list = Magick::Image.read(ActiveStorage::Blob.service.send(:path_for, @logo.image.key))
    @image = @image_list[0]
    @image = @image.sample(100, 100)
  end 

  def posterize
    level = @logo.posterization_level.to_i
    temp_path = "public/logos/posterized_logo_#{@logo.name}"
    @image = @image.posterize(level)
    @image.write temp_path
    @logo.posterized_image.attach(io: StringIO.open(@image.to_blob), filename: "posterized_logo_#{@logo.name}")
    File.delete temp_path
  end 

  def convert_original
    temp_path = "public/logos/converted_logo_#{@logo.name}"
    @image = convert_image(@image)
    @image.write temp_path
    @logo.image_converted.attach(io: StringIO.open(@image.to_blob), filename: "converted_logo_#{@logo.name}")
    File.delete temp_path
  end 

  def convert_posterized
    level = @logo.posterization_level.to_i
    temp_path = "public/logos/posterized_converted_logo_#{@logo.name}"
    @image.posterize(level)
    @image = convert_image(@image)
    @image.write temp_path
    @logo.posterized_image_converted.attach(io: StringIO.open(@image.to_blob), filename: "posterized_converted_logo_#{@logo.name}")
    File.delete temp_path
  end 

  def convert_image(image)
    # resize the image to 100x100
    require 'pry'; binding.pry
    image.sample!(100, 100)
    table = CSV.read(('public/jakesSuperColors.csv'), headers: true)

    image.each_pixel do |pixel, column, row|
      pixel_data = { :hue => standardized_hue(pixel),
                     :saturation => standardized_saturation(pixel),
                     :lightness => standardized_light(pixel),
                     :alpha => pixel.to_hsla[3],
                     :record_num => "#{standardized_light(pixel)}.#{standardized_hue(pixel)}" }

      binding.pry
      # find the closest match in the table
      hex_code = ''
      table.each do |row|
        if (pixel_data[:lightness] == 0)
          hex_code = '#000000'
          break
        end 
        if (pixel_data[:lightness] == 100)
          hex_code = '#ffffff'
          break
        end
        if (row['RecordID'] == pixel_data[:record_num])
          hex_code = row[pixel_data[:saturation].to_s]
          break
        end
      end

      rgb_values = RGB_COLORS_COTTON.select{ |_, v| v == RGB_COLORS_COTTON[YARN_COLORS_COTTON.key(hex_code)]}.values[0]

      pixel_data[:red] = rgb_values[0]
      pixel_data[:green] = rgb_values[1]
      pixel_data[:blue] = rgb_values[2]

      # replace the pixel with the closest match
      image.pixel_color(column, row, Magick::Pixel.new(pixel_data[:red], pixel_data[:green], pixel_data[:blue], pixel_data[:alpha]))

      #need to do quantum range here
    end
    image
  end

  private

  def standardized_hue(pixel)
    original_hue = pixel.to_hsla[0]
    hue = original_hue.round
    if (hue == 0)
        hue = 1
    end 
    hue
  end 

  def standardized_saturation(pixel)
    original_saturation = pixel.to_hsla[1]
    saturation = ((original_saturation/255.0)*100).round
    if (saturation == 0)
        saturation = 1
    end
    saturation
  end

  def standardized_light(pixel)
    original_light = pixel.to_hsla[2]
    light = ((original_light/255.0)*100).round(-1)
    if (light >= 90)
      if (light < 93)
          light = 90
      elsif (light < 98 && light > 92)
          light = 95
      else
          light = 100
      end
    end
    light
  end 
end
