require 'spec_helper'

describe TemplateRepoProviderSerializer do
  let(:template_repo_provider) { GithubTemplateRepoProvider.new }

  it 'exposes the attributes to be jsonified' do
    serialized = described_class.new(template_repo_provider).as_json
    expected_keys = [
        :id,
        :name
    ]
    expect(serialized.keys).to match_array expected_keys
  end

end
