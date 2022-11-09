class LogosController < ApplicationController
    include Rails.application.routes.url_helpers
    before_action only: %i[ show edit update destroy ]

    # GET /logos or /logos.json
    def index
        @logos = Logo.all
    end

    # GET /logos/1 or /logos/1.json
    def show
        @logos = Logo.all
    end

    # GET /logos/new
    def new
        Logo.destroy_all
        @logo = Logo.new
    end

    # GET /logos/1/edit
    def edit
    end

    # POST /logos or /logos.json
    def create
        @logo = Logo.new(logo_params)
        session[:logo_id] = @logo.id
        @logo.save
        redirect_to :action => 'convert'

        # array = []
        # array.push({image: nil, name: 'Baptist Church Group', file_name: 'Baptist.png', file_path: 'public/logos/Baptist.png', file_type: 'image/png'})
        # array.push({image: nil, name: 'Cartoon Network', file_name: 'CartoonNetwork.png', file_path: 'public/logos/CartoonNetwork.png', file_type: 'image/png'})
        # array.push({image: nil, name: 'Chrome', file_name: 'Chrome.png', file_path: 'public/logos/Chrome.png', file_type: 'image/png'})
        # array.push({image: nil, name: 'CLD', file_name: 'CLD.png', file_path: 'public/logos/CLD.png', file_type: 'image/png'})
        # array.push({image: nil, name: 'CocaCola', file_name: 'CocaCola.png', file_path: 'public/logos/CocaCola.png', file_type: 'image.png'})
        # array.push({image: nil, name: 'EMU', file_name: 'EMU.png', file_path: 'public/logos/EMU.png', file_type: 'image/png'})
        # array.push({image: nil, name: 'FedEx', file_name: 'FedEx.jpg', file_path: 'public/logos/FedEx.jpg', file_type: 'image/jpg'})
        # array.push({image: nil, name: 'Five', file_name: 'Five.png', file_path: 'public/logos/Five.png', file_type: 'image/png'})
        # array.push({image: nil, name: 'GatorNation', file_name: 'GatorNation.png', file_path: 'public/logos/GatorNation.png', file_type: 'image/png'})
        # array.push({image: nil, name: 'Luamatics', file_name: 'Laumatics.png', file_path: 'public/logos/Laumatics.png', file_type: 'image/png'})
        # array.push({image: nil, name: 'Mickey', file_name: 'Mickey.png', file_path: 'public/logos/Mickey.jpg', file_type: 'image/png'})
        # array.push({image: nil, name: 'PlayStation', file_name: 'PlayStation.png', file_path: 'public/logos/PlayStation.png', file_type: 'image/png'})
        # array.push({image: nil, name: 'Red', file_name: 'Red.png', file_path: 'public/logos/Red.png', file_type: 'image/png'})
        # array.push({image: nil, name: 'Starbucks', file_name: 'Starbucks.png', file_path: 'public/logos/Starbucks.png', file_type: 'image/png'})
        # array.push({image: nil, name: 'Yahoo', file_name: 'Yahoo.png', file_path: 'public/logos/Yahoo.png', file_type: 'image/png'})         
        # array.each do |x|
            # @logo = Logo.new(logo_params)
            # @logo.name = x[:name]
            # @logo.file_name = x[:file_name]
            # @logo.file_path = x[:file_path]
            # @logo.file_type = x[:file_type]
            # @logo.image.attach(io: File.open(x[:file_path].to_s), filename: x[:file_name], content_type: x[:file_type])
            # session[:logo_id] = @logo.id
            # @logo.save
        # end
        # redirect_to root_path
    end

    def manipulate
        @logos = Logo.all
        @logos.each do |logo|
            LogoConverter.new(logo).manipulate_images
            logo.save
        end 
        redirect_to root_path
    end 

    def convert
        @logos = Logo.all
        @logos.each do |logo|
            # LogoConverter.new(logo).posterize
            LogoConverter.new(logo).convert_original
            # LogoConverter.new(logo).convert_posterized
            logo.save
        end
        redirect_to root_path
    end 

    # PATCH/PUT /logos/1 or /logos/1.json
    def update
        respond_to do |format|
            if @logo.update(logo_params)
                format.html { redirect_to logo_url(@logo), notice: "Logo was successfully updated." }
                format.json { render :show, status: :ok, location: @logo }
            else
                format.html { render :edit, status: :unprocessable_entity }
                format.json { render json: @logo.errors, status: :unprocessable_entity }
            end
        end
    end

    # DELETE /logos/1 or /logos/1.json
    def destroy
        @logo.destroy

        respond_to do |format|
        format.html { redirect_to logos_url, notice: "Logo was successfully destroyed." }
        format.json { head :no_content }
        end
    end

    private
        # Only allow a list of trusted parameters through.
        def logo_params
            params.require(:logo).permit(:image, :name, :posterization_level)
        end
end

