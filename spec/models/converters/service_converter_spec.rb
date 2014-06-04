require 'spec_helper'

describe Converters::ServiceConverter do

  let(:service1){ services(:service1) }
  subject{ described_class.new(service1) }

  it 'creates an Image from the given Service' do
    expect(subject.to_image).to be_a Image
  end

  context 'when handling linked services' do
    before do
      service1.links.create(linked_to_service: services(:service2), alias: 'DB')
    end

    it 'populates the image links' do
      expect(subject.to_image.links).to eql [{"service"=>"my-other-service", "alias"=>"DB"}]
    end
  end

  context 'when handling service categories' do
    before do
      service1.categories.build(app_category: app_categories(:category1))
    end

    it 'populates the category names' do
      expect(subject.to_image.categories).to match_array ['category1']
    end
  end
end
