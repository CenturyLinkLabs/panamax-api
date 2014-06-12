module TemplateBuilder
  class FromJson

    attr_reader :params

    def initialize(json)
      @params = YAML.load(json || '')
    end

    def create_template
      images_hash = params.delete('images')
      Template.create(params) do |t|
        t.images = create_images(images_hash) if images_hash
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
