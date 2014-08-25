require 'spec_helper'

describe ServiceManager do

  let(:service_name) { 'wordpress' }
  let(:image_name) { 'some_image' }
  let(:service_description) { 'A wordpress service' }
  let(:service_state) do
    {
      'node' => {
        'value' => '{"loadState":"loaded"}'
      }
    }
  end

  let(:fake_fleet_client) do
    double(:fake_fleet_client,
      load: true,
      start: true,
      stop: true,
      destroy: true
    )
  end

  let(:service) do
    Service.new(
      name: service_name,
      description: service_description,
      from: image_name
    )
  end

  subject { described_class.new(service) }

  before do
    Fleet.stub(:new).and_return(fake_fleet_client)
  end

  describe '.load' do

    let(:dummy_manager) { double(:dummy_manager, load: true) }

    before do
      described_class.stub(new: dummy_manager)
    end

    it 'news an instance of itself' do
      expect(described_class).to receive(:new).with(service).and_return(dummy_manager)
      described_class.load(service)
    end

    it 'invokes load on manager instance' do
      expect(dummy_manager).to receive(:load)
      described_class.load(service)
    end
  end

  describe '.start' do

    let(:dummy_manager) { double(:dummy_manager, start: true) }

    before do
      described_class.stub(new: dummy_manager)
    end

    it 'news an instance of itself' do
      expect(described_class).to receive(:new).with(service).and_return(dummy_manager)
      described_class.start(service)
    end

    it 'invokes start on manager instance' do
      expect(dummy_manager).to receive(:start)
      described_class.start(service)
    end
  end

  describe '#load' do

    let(:linked_to_service) { Service.new(name: 'linked_to_service') }
    let(:docker_run_string) { 'docker run some stuff' }

    before do
      service.links << ServiceLink.new(
        alias: 'DB',
        linked_to_service: linked_to_service
      )
      service.stub(docker_run_string: docker_run_string)
    end

    it 'submits a service definition to the fleet service' do
      expect(fake_fleet_client).to receive(:load) do |name, service_def|
        expect(name).to eq service.unit_name
        expect(service_def).to eq(
          {
            'Unit' => {
              'Description' => service_description,
              'After' => linked_to_service.unit_name,
              'Requires' => linked_to_service.unit_name,
            },
            'Service' => {
              'ExecStartPre' => "-/usr/bin/docker pull #{image_name}",
              'ExecStart' => docker_run_string,
              'ExecStartPost' => "-/usr/bin/docker rm #{service_name}",
              'ExecStop' => "/usr/bin/docker kill #{service_name}",
              'ExecStopPost' => "-/usr/bin/docker rm #{service_name}",
              'Restart' => 'always',
              'RestartSec' => '10',
              'TimeoutStartSec' => '5min'
            }
          }
        )
      end

      subject.load
    end

    it 'returns the result of the fleet call' do
      expect(subject.load).to eql true
    end
  end

  [:start, :stop, :destroy].each do |method|

    describe "##{method}" do

      it "sends a #{method} message to the fleet client" do
        expect(fake_fleet_client).to receive(method).with(service.unit_name)
        subject.send(method)
      end

      it 'returns the result of the fleet call' do
        expect(subject.send(method)).to eql true
      end
    end
  end

  describe '#get_state' do

    let(:fleet_state) do
      { load: 'loaded', run: 'running' }
    end

    before do
      fake_fleet_client.stub(:status).and_return(fleet_state)
    end

    it 'retrieves service state from the fleet client' do
      expect(fake_fleet_client).to receive(:status).with(service.unit_name)
      subject.get_state
    end

    it 'returns the states' do
      expect(subject.get_state).to eq(load: 'loaded', run: 'running')
    end

    context 'when an error occurs while querying fleet' do

      before do
        fake_fleet_client.stub(:status).and_raise('boom')
      end

      it 'returns an empty hash' do
        expect(subject.get_state).to eql({})
      end
    end
  end
end
