require 'spec_helper'

describe TemplateRepoSerializer do
  let(:repo_model) { TemplateRepo.new }

  it 'exposes the attributes to be jsonified' do
    serialized = described_class.new(repo_model).as_json
    expected_keys = [
      :id,
      :name,
      :template_count
    ]
    expect(serialized.keys).to match_array expected_keys
  end

  it 'calculates the Template count for the repository' do
    expect(TemplateRepoSerializer.new(template_repos(:repo1)).template_count).to eq templates.count
  end
end
