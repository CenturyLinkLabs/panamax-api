require 'spec_helper'

describe AppBuilder::FromImage do

  describe '.create_app' do

    let(:options) do
      {
        image: 'someimage',
      }
    end

    it 'persists a new app' do
      expect do
        described_class.create_app(options)
      end.to change(App, :count).by(1)
    end

    it 'returns the new app' do
      expect(described_class.create_app(options)).to be_a(App)
    end

    it 'instantiates the app with the image info' do
      app = described_class.create_app(options)

      expect(app.name).to eq "#{options[:image]}_image"
      expect(app.from).to eq "Template: #{options[:image]}_image"
    end

    it 'instantiates the app with a single service' do
      app = described_class.create_app(options)
      expect(app.services.size).to eq 1
    end

    it 'instantiates the service with the image info' do
      app = described_class.create_app(options)
      service = app.services.first

      expect(service.name).to eq options[:image]
      expect(service.internal_name).to eq options[:image]
      expect(service.from).to eq options[:image]
    end
  end

end
