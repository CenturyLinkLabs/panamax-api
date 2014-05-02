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
      submit: true,
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
    PanamaxAgent.stub(:fleet_client).and_return(fake_fleet_client)
  end

  describe '.submit' do

    let(:dummy_manager) { double(:dummy_manager, submit: true) }

    before do
      described_class.stub(new: dummy_manager)
    end

    it 'news an instance of itself' do
      expect(described_class).to receive(:new).with(service).and_return(dummy_manager)
      described_class.submit(service)
    end

    it 'invokes submit on manager instance' do
      expect(dummy_manager).to receive(:submit)
      described_class.submit(service)
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

    it 'invokes submit on manager instance' do
      expect(dummy_manager).to receive(:start)
      described_class.start(service)
    end
  end


  describe '#submit' do

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
      expect(fake_fleet_client).to receive(:submit) do |service_def|
        expect(service_def.description).to eq service_description
        expect(service_def.after).to eq linked_to_service.unit_name
        expect(service_def.requires).to eq linked_to_service.unit_name
        expect(service_def.exec_start_pre).to eq "-/usr/bin/docker pull #{image_name}"
        expect(service_def.exec_start).to eq docker_run_string
        expect(service_def.exec_start_post).to eq "-/usr/bin/docker rm #{service_name}"
        expect(service_def.exec_stop).to eq "/usr/bin/docker kill #{service_name}"
        expect(service_def.exec_stop_post).to eq "-/usr/bin/docker rm #{service_name}"
        expect(service_def.restart_sec).to eq '10'
        expect(service_def.timeout_start_sec).to eq '5min'
      end

      subject.submit
    end

    it 'returns the result of the fleet call' do
      expect(subject.submit).to eql true
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

    it 'retrieves service state from the fleet client' do
      expect(fake_fleet_client).to receive(:get_state).with(service.unit_name)
      subject.get_state
    end

    it 'returns the state hash w/ normalized keys' do

    end

    context 'when an error occurs while querying fleet' do

      before do
        fake_fleet_client.stub(:get_state).and_raise('boom')
      end

      it 'returns an empty hash' do
        expect(subject.get_state).to eql({})
      end
    end
  end
end
