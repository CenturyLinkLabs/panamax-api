require 'spec_helper'

describe TemplateRepo do
  it { should respond_to(:name) }
  it { should validate_uniqueness_of(:name) }
  it { should validate_presence_of(:name) }

  describe '#files' do
    its(:files) { should be_a TemplateRepo::GithubRepoFileEnumerator }
  end

  describe 'after_destroy callback' do
    it 'destroys all templates in the db sourced from that repo' do
      template_repos(:repo1).destroy
      expect(Template.where(source: template_repos(:repo1).name).count).to eq 0
    end
  end
end
