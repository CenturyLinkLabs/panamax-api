require 'fleet'

class ServiceManager

  POLL_LENGTH = 5
  POLL_INTERVAL = 0.5

  def self.load(service)
    new(service).load
  end

  def self.start(service)
    new(service).start
  end

  def initialize(service)
    @service = service
  end

  def submit
    fleet_client.submit(@service.unit_name, service_def_from_service(@service))
  end

  def load
    fleet_client.load(@service.unit_name)

    # Poll unit state until it is successfully loaded
    poll do
      begin
        state = fleet_client.get_unit_state(@service.unit_name)
        state['systemdLoadState'] == 'loaded'
      rescue Fleet::NotFound
        false
      end
    end
  end

  def start
    fleet_client.start(@service.unit_name)
  end

  def stop
    fleet_client.stop(@service.unit_name)
  end

  def destroy
    fleet_client.destroy(@service.unit_name)

    # Poll unit state until it can't be found
    poll do
      begin
        fleet_client.get_unit_state(@service.unit_name)
        false
      rescue Fleet::NotFound
        true
      end
    end
  end

  def get_state
    states = fleet_client.get_unit_state(@service.unit_name)
    {
      load_state: states['systemdLoadState'],
      active_state: states['systemdActiveState'],
      sub_state: states['systemdSubState']
    }
  rescue
    {}
  end

  private

  def fleet_client
    Fleet.new
  end

  def service_def_from_service(service)

    unit_block = {
      'Description' => service.description
    }

    if service.links.any?
      dep_services = service.links.map do |link|
        link.linked_to_service.unit_name
      end.join(' ')

      unit_block['After'] = dep_services
      unit_block['Requires'] = dep_services
    end

    docker_rm = "-/usr/bin/docker rm #{service.name}"
    service_block = {
      'ExecStartPre' => "-/usr/bin/docker pull #{service.from}",
      'ExecStart' => service.docker_run_string,
      'ExecStop' => "-/usr/bin/docker stop #{service.name}",
      'Restart' => 'always',
      'RestartSec' => '10',
      'TimeoutStartSec' => '5min'
    }

    {
      'Unit' => unit_block,
      'Service' => service_block
    }
  end

  def poll(length=POLL_LENGTH, &block)
    result = (length / POLL_INTERVAL).to_i.times do
      break :success if block.call
      sleep(POLL_INTERVAL)
    end
    result == :success
  end
end
