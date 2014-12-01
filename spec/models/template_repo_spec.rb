require 'spec_helper'

describe TemplateRepo do
  fixtures :template_repo_providers, :template_repos

  it { should respond_to(:name) }
  it { should respond_to(:template_repo_provider) }
  it { should validate_uniqueness_of(:name) }
  it { should validate_presence_of(:name) }

  describe '#files' do
    let(:template_repo_provider) { template_repo_providers(:github) }

    it 'delegates to the template_repo_provider' do
      subject.template_repo_provider = template_repo_provider
      expect(template_repo_provider).to receive(:files_for).with(subject)
      subject.files
    end
  end

  describe 'after_create callback' do
    it 'reloads the repo templates' do
      repo = TemplateRepo.new(name: 'fizz/buzz')
      expect(repo).to receive(:reload_templates)
      repo.save!
    end
  end

  describe 'after_destroy callback' do
    it 'destroys all templates in the db sourced from that repo' do
      template_repos(:repo1).destroy
      expect(Template.where(source: template_repos(:repo1).name).count).to eq 0
    end
  end

  describe '#load_templates' do

    let(:template) { Template.new }
    let(:file1) { double(:file, name: 'readme', content: 'hi') }
    let(:file2) { double(:file, name: 'foo.pmx', content: 'bar') }

    before do
      subject.name = 'my/repo'
      allow(subject).to receive(:files).and_return([file1, file2])
      allow(subject).to receive(:touch).and_return(true)
      allow(TemplateBuilder).to receive(:create).and_return(template)
    end

    it 'invokes the TemplateBuilder ONLY for .pmx files' do
      expect(TemplateBuilder).to receive(:create).once
      subject.load_templates
    end

    it 'invokes the TemplateBuilder with .pmx file contents' do
      expect(TemplateBuilder).to receive(:create).with(file2.content)
      subject.load_templates
    end

    it 'sets the repo name on the source field of the template' do
      subject.load_templates
      expect(template.source).to eql subject.name
    end

    it 'updates the updated_at value' do
      repo = template_repos(:repo1)
      allow(repo).to receive(:files).and_return([])
      expect { repo.load_templates }.to change(repo, :updated_at)
    end

  end

  describe '.load_templates_from_all_repos' do

    let(:fake_repo) { double('fake_repo', load_templates: true) }

    before do
      allow(described_class).to receive(:all).and_return([fake_repo])
    end

    it 'invokes load_templates for each repo' do
      expect(fake_repo).to receive(:load_templates).once
      described_class.load_templates_from_all_repos
    end
  end

  describe '#reload_templates' do

    it 'purges and reloads templates' do
      repo = TemplateRepo.new
      expect(repo).to receive(:purge_templates)
      expect(repo).to receive(:load_templates)
      repo.reload_templates
    end

    it 'updates the updated_at value' do
      repo = template_repos(:repo1)
      allow(repo).to receive(:files).and_return([])
      expect { repo.reload_templates }.to change(repo, :updated_at)
    end

  end

end
