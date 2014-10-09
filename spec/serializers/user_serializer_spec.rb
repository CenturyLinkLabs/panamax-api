require 'spec_helper'

describe UserSerializer do
  let(:user_model) { User.new }

  before do
    Octokit::Client.any_instance.stub(:repos).and_return([])
  end

  it 'exposes the attributes to be jsonified' do
    serialized = described_class.new(user_model).as_json
    expected_keys = [:email, :repos, :template_repo_providers, :username]
    expect(serialized.keys).to match_array expected_keys
  end

  context "when the user has a github template repo provider" do

    let(:github_repo_provider) do
      GithubTemplateRepoProvider.new(
          name: 'GitHub',
          credentials: double('creds', { account: 'some user', api_key: '1234' }),
      )
    end

    before do
      user_model.stub(:template_repo_providers).and_return([github_repo_provider])
    end

    it 'exposes the attributes to be jsonified' do
      serialized = described_class.new(user_model).as_json
      expected_keys = [
                        :email,
                        :repos,
                        :github_access_token_present,
                        :github_username,
                        :template_repo_providers,
                        :username
                      ]
      expect(serialized.keys).to match_array expected_keys
    end
  end
end
