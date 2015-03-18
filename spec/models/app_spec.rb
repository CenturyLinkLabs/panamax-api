require 'spec_helper'

describe App do
  fixtures :apps
  subject { apps(:app1) }

  before do
    allow_any_instance_of(Service).to receive(:shutdown)
  end

  it { should have_many(:services) }
  it { should have_many(:categories).class_name('AppCategory').dependent(:destroy) }

  describe '#run' do

    let(:s1) { Service.new(name: 's1') }
    let(:s2) { Service.new(name: 's2') }

    before do
      subject.services = [s1, s2].each do |s|
        allow(s).to receive(:submit).and_return(true)
        allow(s).to receive(:load).and_return(true)
        allow(s).to receive(:start).and_return(true)
      end
    end

    it 'submits each service' do
      expect(s1).to receive(:submit)
      expect(s2).to receive(:submit)
      subject.run
    end

    it 'submits each service' do
      expect(s1).to receive(:load)
      expect(s2).to receive(:load)
      subject.run
    end

    it 'runs each service' do
      expect(s1).to receive(:start)
      expect(s2).to receive(:start)
      subject.run
    end
  end

  describe '#restart' do

    let(:s1) { Service.new(name: 's1') }
    let(:s2) { Service.new(name: 's2') }

    before do
      subject.services = [s1, s2]
      subject.services.each do |s|
        allow(s).to receive(:shutdown)
        allow(s).to receive(:submit)
        allow(s).to receive(:load)
        allow(s).to receive(:start)
      end
    end

    it 'shutsdown each service' do
      expect(s1).to receive(:shutdown)
      expect(s2).to receive(:shutdown)
      subject.restart
    end

    it 'submits each service' do
      expect(s1).to receive(:submit)
      expect(s2).to receive(:submit)
      subject.restart
    end

    it 'loads each service' do
      expect(s1).to receive(:load)
      expect(s2).to receive(:load)
      subject.restart
    end

    it 'starts each service' do
      expect(s1).to receive(:start)
      expect(s2).to receive(:start)
      subject.restart
    end
  end

  describe '#add_service' do
    fixtures :app_categories, :services

    let(:category) { subject.categories.first }
    let(:linked_to_service) { subject.services.last }

    let(:params) do
      {
        name: 'foo_bar',
        description: 'my foo service',
        from: 'some image',
        categories: [{ id: category.id }],
        ports: [{ host_interface: '', host_port: '', 'container_port' => 90, proto: '' }],
        expose: ['1111'],
        links: [{ service_id: linked_to_service.id, alias: 'DEP' }],
        volumes: [{ 'host_path' => '', 'container_path' => '/foo/baz' }],
        environment: [{ 'variable' => 'SOME_KEY', 'value' => '' }]
      }
    end

    before do
      allow(subject).to receive(:resolve_name_conflicts).and_return(true)
    end

    it 'creates a new service' do
      result = subject.add_service(params)
      expect(result.name).to eq params[:name]
      expect(result.from).to eq params[:from]
    end

    it 'increments the service count' do
      expect do
        subject.add_service(params)
      end.to change { Service.count }.by(1)
    end

    it 'adds the service to the existing app' do
      subject.add_service(params)
      subject.reload
      expect(Service.last.app).to eq subject
    end

    it 'increments the app services count' do
      expect do
        subject.add_service(params)
        subject.reload
      end.to change { subject.services.count }.by(1)
    end

    it 'increments the service link count' do
      expect do
        subject.add_service(params)
      end.to change { ServiceLink.count }.by(1)
    end

    it 'associates the service to the correct category' do
      subject.add_service(params)
      subject.reload
      expect(Service.last.categories.first.app_category_id).to eq category.id
    end
  end

end
