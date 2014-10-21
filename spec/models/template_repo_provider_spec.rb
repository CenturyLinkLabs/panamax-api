require 'spec_helper'

describe TemplateRepoProvider do

  it { should belong_to(:user) }

  describe '#credentials' do
    it 'returns a TemplateRepoProviderCredentials instance' do
      expect(subject.credentials).to be_a TemplateRepoProviderCredentials
    end

    context 'when credentials are set on the provider' do
      before do
        subject.credentials_account = 'foo'
        subject.credentials_api_key = 'bar'
      end

      it 'allows access to the credentials_account and credentials_api_key values of the provider' do
        creds = subject.credentials
        expect(creds.account).to eq subject.credentials_account
        expect(creds.api_key).to eq subject.credentials_api_key
      end
    end
  end

  describe '#credentials=' do
    let(:credentials) { TemplateRepoProviderCredentials.new('foo', 'bar') }

    it 'sets the provider credentials_account and credentials_api_key values' do
      subject.credentials = credentials
      expect(subject.credentials_account).to eq credentials.account
      expect(subject.credentials_api_key).to eq credentials.api_key
    end
  end

  describe '.find_or_create_default_for' do
    let(:user) { User.instance }
    subject(:find_or_create) { described_class.find_or_create_default_for(user) }

    it { should be_a GithubTemplateRepoProvider }

    context 'when the user does not have a GitHub repo provider' do
      it 'adds a new provider to the user template_repo_providers collection' do
        expect{ find_or_create }.to change{ user.template_repo_providers.count }.by(1)
      end
    end

    context 'when the user already has a GitHub repo provider' do
      let(:provider) { GithubTemplateRepoProvider.new(credentials_api_key: 'asdf') }
      before do
        user.template_repo_providers << provider
      end

      it 'does not add a new provider to the user template_repo_providers collection' do
        expect{ find_or_create }.not_to change{ user.template_repo_providers.count }
      end

      it 'returns the repo provider' do
        expect(find_or_create).to eq(provider)
      end
    end

  end
end
