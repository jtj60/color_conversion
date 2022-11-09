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
        @image = convert_colors(@image)
        @image.write temp_path
        @logo.image_converted.attach(io: StringIO.open(@image.to_blob), filename: "converted_logo_#{@logo.name}")
        File.delete temp_path
    end 

    def convert_posterized
        level = @logo.posterization_level.to_i
        temp_path = "public/logos/posterized_converted_logo_#{@logo.name}"
        @image.posterize(level)
        @image = convert_colors(@image)
        @image.write temp_path
        @logo.posterized_image_converted.attach(io: StringIO.open(@image.to_blob), filename: "posterized_converted_logo_#{@logo.name}")
        File.delete temp_path
    end 

    def hue_rounding(h)
        h = h.round
        if (h == 0)
            h = 1
        end 
        return h
    end 

    def saturation_rounding(s)
        s = ((s/255.0)*100).round
        if (s == 0)
            s = 1
        end
        return s
    end

    def light_rounding(l)
        l = ((l/255.0)*100).round(-1)
        if (l >= 90)
            if (l < 93)
                l = 90
            elsif (l < 98 && l > 92)
                l = 95
            else
                l = 100
            end
        end
        return l
    end 

    def hsl_conversion (pixel)
        r = pixel[0]/255.0
        g = pixel[1]/255.0
        b = pixel[2]/255.0
        max = [r, g, b].max
        min = [r, g, b].min
        h = (max + min) / 2.0
        s = (max + min) / 2.0
        l = (max + min) / 2.0

        if(max == min)
            h = 0
            s = 0
        else
            d = max - min;
            s = l >= 0.5 ? d / (2.0 - max - min) : d / (max + min)
            case max
                when r 
                    h = (g - b) / d + 0.0
                when g 
                    h = (b - r) / d + 2.0
                when b 
                    h = (r - g) / d + 4.0
            end
            h /= 6.0
        end

        pixel[0] = (h*360).round
        pixel[1] = (s*100).round
        pixel[2] = (l*100).round

        if (pixel[0] < 0)
            pixel[0] = pixel[0] + 360
        end 
        return pixel
    end 

    # def convert_back_to_hsla(pixel)
    #     pixel[0] = pixel[0].round
    #     pixel[1] = ((pixel[1]/100) * 255).round
    #     pixel[2] = ((pixel[2]/100) * 255).round
    #     return pixel 
    # end 

    def convert_colors(image)
        table = CSV.read(('public/jakesSuperColors.csv'), headers: true)
        pixels = image.get_pixels(0, 0, image.columns, image.rows)
        hex_code = ''

        pixels.each_with_index do |orig_pixel, i|
 
            pixel = orig_pixel.to_hsla
            
            p 'hue 1:', pixel[0]
            p 'saturation 1', pixel[1]
            p 'light 1:', pixel[2]
            hue = hue_rounding(pixel[0])
            saturation = saturation_rounding(pixel[1])
            light = light_rounding(pixel[2])
            record = light.to_s + '.' + hue.to_s
            table.each do |row|
                if (light == 0)
                    hex_code = '#000000'
                    break
                end 
                if (light == 100)
                    hex_code = '#ffffff'
                    break
                end
                if (row['RecordID'] == record)
                    hex_code = row[saturation.to_s]
                    break
                end
            end
            temp_pixel = RGB_COLORS_COTTON.select{ |_, v| v == RGB_COLORS_COTTON[YARN_COLORS_COTTON.key(hex_code)]}.values[0]
            pixel[0] = temp_pixel[0]
            pixel[1] = temp_pixel[1]
            pixel[2] = temp_pixel[2]
            p 'r:', pixel[0]
            p 'g', pixel[1]
            p 'b:', pixel[2]
            pixel = hsl_conversion(pixel)
            p 'hue 2:', pixel[0]
            p 'saturation 2', pixel[1]
            p 'light 2:', pixel[2]
            orig_pixel = Magick::Pixel.from_hsla(pixel[0], pixel[1], pixel[2], pixel[3])
            
            p 'After Conversion: ', orig_pixel
            p '__________________'
        end
        
        image.store_pixels(0, 0, image.columns, image.rows, pixels)

        return image
    end 
#         table = CSV.read(('public/jakesSuperColors.csv'), headers: true)
#         pixels = image.get_pixels(0, 0, image.columns, image.rows)
#         hex_code = ''
#         pixel_array.each do |pixel|
#             unless unique_colors.key?(pixel)
#                 unique_colors_converted[pixel] = pixel
#                 unique_colors[pixel] = pixel
#             end
#         end 
#         p unique_colors
#         p unique_colors_converted

#         table = CSV.read(('public/jakesSuperColors.csv'), headers: true)
#         pixel_array.each do |pixel|
#             hue = hue_rounding(pixel[0])
#             saturation = saturation_rounding(pixel[1])
#             light = light_rounding(pixel[2])
#             record = light.to_s + '.' + hue.to_s
#             p 'Pixel:', pixel
#             p 'Hue: ', hue
#             p 'Saturation:', saturation
#             p 'Light', light
#             p 'Record:', record

#             table.each do |row|
#                 if (light == 0)
#                     hex_code = '#000000'
#                     break
#                 end 
#                 if (light == 100)
#                     hex_code = '#ffffff'
#                     break
#                 end
#                 if (row['RecordID'] == record)
#                     hex_code = row[saturation.to_s]
#                     break
#                 end
#             end
            
#             temp_pixel = RGB_COLORS_COTTON.select{ |_, v| v == RGB_COLORS_COTTON[YARN_COLORS_COTTON.key(hex_code)]}.values[0]
#             # p 'Hex Code:', hex_code
#             # p 'Temp Pixel:', temp_pixel
#             # p 'Before Conversion:', unique_colors_converted[pixel]
#             pixel[0] = temp_pixel[0]
#             pixel[1] = temp_pixel[1]
#             pixel[2] = temp_pixel[2]
#             unique_colors[pixel] = pixel
#             unique_colors_converted[pixel] = pixel
#             # p 'After Conversion:', unique_colors_converted[pixel]
#             # p '___________________'
#         end
#         p unique_colors_converted
#         pixel_array.each_with_index do |pixel, i| 
#             mapped_pixels[i] << unique_colors_converted[pixel]
#         end
#         mapped_pixels = []
#         pixel_array.each_with_index do |pixel, i|
#             mapped_pixels[i] = Magick::Pixel.new(pixel[0], pixel[1], pixel[2], pixel[3])
#         end

#         converted_image = Magick::Image.new(image.columns, image.rows)
#         converted_image.import_pixels(0, 0, image.columns, image.rows, "RGBA", mapped_pixels)

#         return converted_image
#     end
# end


# 1) get image
#     a) rmagick or mini magick methods 
# 2) do transformations
# 3) convert to sc yarn
#     a) get pixels
#     b) unique colors method??
#     c) 
# 4) save image 