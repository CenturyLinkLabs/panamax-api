require 'spec_helper'

describe UserSerializer do
  let(:user_model) { User.new }

  before do
    Octokit::Client.any_instance.stub(:repos).and_return([])
  end

  it 'exposes the attributes to be jsonified' do
    serialized = described_class.new(user_model).as_json
    expected_keys = [:email, :repos, :github_access_token_present, :github_username]
    expect(serialized.keys).to match_array expected_keys
  end
end
