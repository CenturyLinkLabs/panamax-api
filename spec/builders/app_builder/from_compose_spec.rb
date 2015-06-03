require 'spec_helper'

describe AppBuilder::FromCompose do
  describe '.create_app' do
    let(:options) { { compose_yaml: '---\n' } }
    let(:app) { App.new(name: 'myapp') }
    let(:converter) { double(:converter, to_app: app) }

    context 'when the intermediate template created has no errors' do
      let(:template) { double(:template, valid?: true) }

      before do
        allow(TemplateBuilder).to receive(:create).with(options, false).and_return(template)
        allow_any_instance_of(Converters::TemplateConverter).to receive(:to_app).and_return(app)
      end

      it 'creates a template with the provided options' do
        expect(TemplateBuilder).to receive(:create).with(options, false).and_return(template)
        described_class.create_app(options)
      end

      it 'instantiates a converter with the template' do
        expect(Converters::TemplateConverter).to(
          receive(:new).with(template).and_return(converter))

        described_class.create_app(options)
      end

      it 'persists a new app' do
        expect do
          described_class.create_app(options)
        end.to change(App, :count).by(1)
      end

      it 'returns the new app' do
        expect(described_class.create_app(options)).to eql app
      end
    end

    context 'when the intermediate template created has errors' do
      let(:template) { double(:template, valid?: false) }

      before do
        allow(TemplateBuilder).to receive(:create).with(options, false).and_return(template)
      end

      it 'raises an error' do
        expect do
          described_class.create_app(options)
        end.to raise_error
      end
    end
  end
end
