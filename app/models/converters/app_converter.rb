module Converters
  class AppConverter
    DOCKER_COMPOSE_FILENAME = 'docker-compose.yml'

    attr_reader :app

    def initialize(app)
      @app = app
    end

    def to_template
      images = app.services.map { |service| service_to_image(service) }
      Template.new(name: app.name, documentation: app.documentation, images: images)
    end

    def to_compose_yaml
      compose_hash = app.services.each_with_object({}) do |service, hash|
        hash.merge!(ServiceConverter.new(service).to_compose_hash)
      end
      compose_hash.to_yaml
    end

    def to_compose_gist(filename=DOCKER_COMPOSE_FILENAME)
      github_client.create_gist(description: 'created by Panamax',
                                public: true,
                                files: { filename => { content: to_compose_yaml } })
    end

    private

    def github_client
      @github_client ||= Octokit::Client.new
    end

    def service_to_image(service)
      ServiceConverter.new(service).to_image
    end
  end
end
