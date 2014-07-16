module TemplateBuilder
  class FromJson

    attr_reader :params

    def initialize(json)
      @params = YAML.safe_load(json || '')
    end

    def create_template(persisted=true)
      images_hash = params.delete('images')
      Template.new(params) do |template|
        template.images = create_images(images_hash) if images_hash
        template.save if persisted
      end
    end

    private

    def create_images(images_hash)
      images_hash.map do |image_hash|
        image_hash['categories'] = Array(image_hash.delete('category'))
        Image.new(image_hash)
      end
    end

  end
end
