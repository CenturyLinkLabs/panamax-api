require 'spec_helper'

describe Converters::ServiceConverter do
  fixtures :services
  fixtures :app_categories
  let(:service1) { services(:service1) }
  let(:service2) { services(:service2) }
  subject { described_class.new(service1) }

  describe '#to_compose_service' do
    it 'creates a ComposeService from the given Service' do
      expect(subject.to_compose_service).to be_a ComposeService
    end

    it 'copies the service name' do
      expect(subject.to_compose_service.name).to eq service1.name
    end

    it 'copies the exposed ports' do
      expect(subject.to_compose_service.expose).to eq service1.expose
    end

    it 'converts the service ports' do
      service1.ports << {
        'host_interface' => '127.0.0.1',
        'host_port' => 8080,
        'container_port' => 8081,
        'proto' => 'UDP'
      }
      expect(subject.to_compose_service.ports).to eq(['3306:3306', '127.0.0.1:8080:8081/udp'])
    end

    it 'converts the service links when present'do
      service1.links << ServiceLink.new(linked_to_service: service2, alias: 'other')
      expect(subject.to_compose_service.links).to eq(['my-other-service:other'])
    end

    it 'does not include the service links when not present'do
      expect(subject.to_compose_service.links).to be_nil
    end

    it 'converts the service environment variables'do
      expect(subject.to_compose_service.environment).to eq(['MYSQL_ROOT_PASSWORD=pass@word01'])
    end

    it 'converts the service volumes'do
      expect(subject.to_compose_service.volumes).to eq(['/var/panamax:/var/app/panamax'])
    end

    it 'converts the service volumes_from'do
      service1.volumes_from << SharedVolume.new(exported_from_service: service2)
      expect(subject.to_compose_service.volumes_from).to eq(['my-other-service'])
    end

    it 'copies the service command' do
      expect(subject.to_compose_service.command).to eq(service1.command)
    end
  end

  describe '#to_image' do

    it 'creates an Image from the given Service' do
      expect(subject.to_image).to be_a Image
    end

    it 'copies the service name' do
      expect(subject.to_image.name).to eq service1.name
    end

    it 'copies the service description' do
      expect(subject.to_image.description).to eq service1.description
    end

    it 'copies the category names' do
      expect(subject.to_image.categories).to eq service1.categories.map(&:name)
    end

    it 'copies the service from string' do
      expect(subject.to_image.source).to eq service1.from
    end

    it 'copies the service ports' do
      expect(subject.to_image.ports).to eq service1.ports
    end

    it 'copies the service expose ports' do
      expect(subject.to_image.expose).to eq service1.expose
    end

    it 'copies the service environment' do
      expect(subject.to_image.environment).to eq service1.environment
    end

    it 'copies the service volumes' do
      expect(subject.to_image.volumes).to eq service1.volumes
    end

    it 'copies the service command' do
      expect(subject.to_image.command).to eq service1.command
    end

    it 'copies the service type' do
      expect(subject.to_image.type).to eq service1.type
    end

    context 'when handling linked services' do
      before do
        service1.links.create(linked_to_service: services(:service2), alias: 'DB')
      end

      it 'populates the image links' do
        expect(subject.to_image.links).to eql [{ 'service' => 'my-other-service', 'alias' => 'DB' }]
      end
    end

    context 'when handling service categories' do
      before do
        service1.categories.create(app_category: app_categories(:category1))
      end

      it 'populates the image categories' do
        expect(subject.to_image.categories).to eq [app_categories(:category1).name]
      end
    end

    context 'when handling services with volumes_from' do
      before do
        service1.volumes_from.create(exported_from_service: services(:service2))
      end

      it 'populates the image with volumes_from' do
        expect(subject.to_image.volumes_from).to eql [{ 'service' => 'my-other-service' }]
      end
    end

  end
end
