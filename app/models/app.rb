class App < ActiveRecord::Base
  has_many :services

  def self.create_from_template(t)
    transaction do
      app = self.create(name: t.name, from: "Template: #{t.name}")
      t.images.each do |i|
        app.services.create(
            name: i.repository,
            description: i.description,
            from: "#{i.repository}:#{i.tag}",
            links: i.links,
            ports: i.ports,
            expose: i.expose,
            environment: i.environment,
            volumes: i.volumes
        )
      end
      app
    end
  end

  def self.create_from_image(image_create_params)
    puts image_create_params
    transaction do
      app = self.create(name: image_create_params[:image], from: "Image: #{image_create_params[:image]}")
      app.services.create(
          name: "#{image_create_params[:image].gsub('/', '_')}.service",
          from: "#{image_create_params[:image]}:#{image_create_params[:tag]}",
          links: image_create_params[:links],
          ports: image_create_params[:ports],
          expose: image_create_params[:expose],
          environment: image_create_params[:environment],
          volumes: image_create_params[:volumes]
      )
      app
    end
  end
end
