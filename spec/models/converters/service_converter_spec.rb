require 'spec_helper'

describe Converters::ServiceConverter do

  let(:service1) { services(:service1) }
  subject { described_class.new(service1) }

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
        service1.categories.build(app_category: app_categories(:category1))
      end
    end
  end
end
