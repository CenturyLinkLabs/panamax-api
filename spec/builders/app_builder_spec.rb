require 'spec_helper'

describe AppBuilder do

  let(:app) { double(:app) }

  describe '.create' do

    context 'when a template ID is provided' do

      let(:options) { { template_id: 't123' } }

      before do
        allow(AppBuilder::FromTemplate).to receive(:create_app).and_return(app)
      end

      it 'invokes the FromTemplate strategy' do
        expect(AppBuilder::FromTemplate).to receive(:create_app)
        described_class.create(options)
      end

      it 'returns the new app' do
        expect(described_class.create(options)).to eq app
      end
    end

    context 'when an image is provided' do

      let(:options) { { image: 'foo/bar' } }

      before do
        allow(AppBuilder::FromImage).to receive(:create_app).and_return(app)
      end

      it 'invokes the FromImage strategy' do
        expect(AppBuilder::FromImage).to receive(:create_app)
        described_class.create(options)
      end

      it 'returns the new app' do
        expect(described_class.create(options)).to eq app
      end
    end
  end
end
