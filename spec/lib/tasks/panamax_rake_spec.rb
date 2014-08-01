require 'spec_helper'

describe 'panamax:templates:load' do
  include_context 'rake'

  before do
    TemplateRepo.stub(:load_templates_from_all_repos)
  end

  its(:prerequisites) { should include('environment') }

  it 'loads templates' do
    expect(TemplateRepo).to receive(:load_templates_from_all_repos)
    subject.invoke
  end
end

describe 'panamax:templates:unload' do
  include_context 'rake'

  before do
    Template.stub(:destroy_all)
  end

  its(:prerequisites) { should include('environment') }

  it 'unloads templates' do
    expect(Template).to receive(:destroy_all)
    subject.invoke
  end
end
