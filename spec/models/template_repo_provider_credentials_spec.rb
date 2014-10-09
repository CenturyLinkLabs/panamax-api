require 'spec_helper'

describe TemplateRepoProviderCredentials do
  describe '#initialize' do

    let(:attrs) { { account: 'foo', api_key: 'bar' } }

    it 'sets specified attributes on model' do
      model = described_class.new(attrs[:account], attrs[:api_key])
      expect(model.account).to eq attrs[:account]
      expect(model.api_key).to eq attrs[:api_key]
    end

  end
end
