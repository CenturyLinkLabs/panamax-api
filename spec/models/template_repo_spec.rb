require 'spec_helper'

describe TemplateRepo do
  it { should respond_to(:name) }
  it { should validate_uniqueness_of(:name) }
  it { should validate_presence_of(:name) }

  describe '#files' do
    its(:files) { should be_a TemplateRepo::GithubRepoFileEnumerator }
  end
end
