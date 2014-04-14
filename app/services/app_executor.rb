class AppExecutor

  def self.run(app)
    new(app).run
  end

  def initialize(app)
    @app = app
  end

  def run
    @app.services.each { |service| fleet_client.submit(service_def_from_service(service)) }
    @app.services.each { |service| fleet_client.start(service.unit_name) }
  end

  private

  def fleet_client
    PanamaxAgent.fleet_client
  end

  def service_def_from_service(service)
    PanamaxAgent::Fleet::ServiceDefinition.new(service.unit_name) do |sd|
      sd.description = service.description

      # Collect service dependencies
      dep_services = service.links.map { |link| "#{link[:service]}.service" }.join(' ')
      sd.after = dep_services
      sd.requires = dep_services

      # The '-' prefix in the docker rm command causes the return value to be
      # ignored. We want to try and remove the container if it has exited, but
      # don't really care if it fails.
      docker_rm = "-/usr/bin/docker rm #{service.name}"

      sd.exec_start_pre = docker_rm
      sd.exec_start = service.docker_run_string
      sd.exec_start_post = docker_rm
      sd.exec_stop = "/usr/bin/docker kill #{service.name}"
      sd.exec_stop_post = docker_rm
      sd.restart_sec = '10'
    end
  end
end
