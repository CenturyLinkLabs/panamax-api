require 'spec_helper'

describe App do
  subject { apps(:app1) }
  it { should have_many(:services) }
  it { should have_many(:categories).class_name('AppCategory').dependent(:destroy) }

  describe '#run' do

    let(:s1) { Service.new(name: 's1') }
    let(:s2) { Service.new(name: 's2') }

    before do
      subject.services = [s1, s2].each { |s| s.stub(submit: true, start: true) }
    end

    it 'submits each service' do
      expect(s1).to receive(:submit)
      expect(s2).to receive(:submit)
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
      subject.stub(:sleep)
      subject.services = [s1, s2]
      subject.services.each do |s|
        s.stub(:shutdown)
        s.stub(:submit)
        s.stub(:start)
      end
    end

    it 'shutsdown each service' do
      expect(s1).to receive(:shutdown)
      expect(s2).to receive(:shutdown)
      subject.restart
    end

    it 'does some sleeping' do
      expect(subject).to receive(:sleep).with(1)
      subject.restart
    end

    it 'submits each service' do
      expect(s1).to receive(:submit)
      expect(s2).to receive(:submit)
      subject.restart
    end

    it 'starts each service' do
      expect(s1).to receive(:start)
      expect(s2).to receive(:start)
      subject.restart
    end
  end

  describe '#add_service' do

    fixtures :app_categories

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
      subject.stub(:resolve_name_conflicts).and_return(true)
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
