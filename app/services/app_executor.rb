
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

  REMOVE_EXITED_CONTAINERS = '/usr/bin/docker ps -a -q | xargs docker rm'

  def service_def_from_service(service)
    sd = PanamaxAgent::Fleet::ServiceDefinition.new(service.unit_name)
    sd.description = service.description

    # Collect service dependencies
    dep_services = service.links.map { |link| "#{link[:service]}.service" }.join(' ')
    sd.after = dep_services
    sd.requires = dep_services

    sd.exec_start_pre = REMOVE_EXITED_CONTAINERS
    sd.exec_start = service.docker_run_string
    sd.exec_start_post = REMOVE_EXITED_CONTAINERS
    sd.exec_stop = "/usr/bin/docker kill #{service.name} ; /usr/bin/docker rm #{service.name}"
    sd.exec_stop_post = REMOVE_EXITED_CONTAINERS
    sd.restart_sec = '10'
    sd
  end

end
