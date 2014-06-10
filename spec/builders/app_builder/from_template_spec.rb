require 'spec_helper'

describe AppBuilder::FromTemplate do

  describe '.create_app' do

    let(:template) { templates(:wordpress) }
    let(:app) { App.new(name: 'myapp') }
    let(:converter) { double(:converter, to_app: app) }

    before do
      Converters::TemplateConverter.any_instance.stub(:to_app).and_return(app)
    end

    it 'instantiates a converter with the template' do
      expect(Converters::TemplateConverter).to(
        receive(:new).with(template).and_return(converter))

      described_class.create_app(template_id: template.id)
    end

    it 'persists a new app' do
      expect do
        described_class.create_app(template_id: template.id)
      end.to change(App, :count).by(1)
    end

    it 'returns the new app' do
      expect(described_class.create_app(template_id: template.id)).to eql app
    end
  end
end
