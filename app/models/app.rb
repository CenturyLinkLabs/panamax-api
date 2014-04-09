class App < ActiveRecord::Base
  has_many :services

  def self.create_from_template(t)
    self.create(name: t.name, from: "Template: #{t.name}") do |app|
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
    end
  end

  def self.create_from_image(image_create_params)
    self.create(name: image_create_params[:image], from: "Image: #{image_create_params[:image]}") do |app|
      #TODO verify that app has been saved
      app.services.create(
          name: image_create_params[:image],
          from: "Image: #{image_create_params[:image]}",
          links: image_create_params[:links],
          ports: image_create_params[:ports],
          expose: image_create_params[:expose],
          environment: image_create_params[:environment],
          volumes: image_create_params[:volumes]
      )
    end
  end
end