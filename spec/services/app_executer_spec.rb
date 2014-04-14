require 'spec_helper'

describe AppExecutor do

  let(:service_name) { 'wordpress.service' }
  let(:service_description) { 'A wordpress service' }
  let(:unit_name) { 'g unit' }
  let(:docker_run_string) { 'docker run some stuff' }

  let(:fake_fleet_client) { double(:fake_fleet_client, submit: true, start: true) }

  let(:fake_service) do
    double(:fake_service, {
      name: service_name,
      unit_name: unit_name,
      description: service_description,
      links: [{service: 'some-service'}],
      docker_run_string: docker_run_string
    })
  end

  let(:fake_service_definition) do
    double(:fake_service_definition).as_null_object
  end

  let(:fake_app) do
    double(:fake_app, {
      services: [fake_service, double(:another_fake_service).as_null_object]
    })
  end

  before do
    PanamaxAgent.stub(:fleet_client).and_return(fake_fleet_client)
    PanamaxAgent::Fleet::ServiceDefinition.stub(:new).and_return(fake_service_definition)
  end

  describe '.run' do

    it 'submits the fleet service with a service definition for each service' do
      expect(fake_service_definition).to receive(:description=).with(service_description)
      expect(fake_service_definition).to receive(:after=).with('some-service.service')
      expect(fake_service_definition).to receive(:requires=).with('some-service.service')
      expect(fake_service_definition).to receive(:exec_start_pre=).with('/usr/bin/docker ps -a -q | xargs docker rm')
      expect(fake_service_definition).to receive(:exec_start=).with(docker_run_string)
      expect(fake_service_definition).to receive(:exec_start_post=).with('/usr/bin/docker ps -a -q | xargs docker rm')
      expect(fake_service_definition).to receive(:exec_stop=).with("/usr/bin/docker kill #{service_name} ; /usr/bin/docker rm #{service_name}")
      expect(fake_service_definition).to receive(:exec_stop_post=).with('/usr/bin/docker ps -a -q | xargs docker rm')
      expect(fake_service_definition).to receive(:restart_sec=).with('10')
      expect(fake_fleet_client).to receive(:submit).with(fake_service_definition)

      described_class.run(fake_app)
    end

    it 'starts the fleet client with each service' do
      expect(fake_fleet_client).to receive(:start).with(unit_name)

      described_class.run(fake_app)
    end

  end

end
