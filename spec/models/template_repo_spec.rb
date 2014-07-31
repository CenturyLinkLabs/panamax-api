require 'spec_helper'

describe TemplateRepo do
  it { should respond_to(:name) }
  it { should validate_uniqueness_of(:name) }
  it { should validate_presence_of(:name) }

  describe '#files' do
    before do
      file_path = File.expand_path('../support/fixtures/sample.tar.gz', __dir__)
      file = File.open(file_path)
      subject.stub(:open).and_return(file)
    end

    it 'returns an array of objects that respond to :name and :content' do
      file = subject.files.first
      expect(file).to respond_to(:name)
      expect(file).to respond_to(:content)
    end

    it 'returns files contained in the archive' do
      file_names = subject.files.map(&:name)
      expect(file_names).to include 'sample/rails.pmx'
      expect(file_names).to include 'sample/README.md'
    end

    it 'excludes directories contained in the archive' do
      file_names = subject.files.map(&:name)
      expect(file_names).to_not include 'sample/'
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
      subject.stub(:files).and_return([file1, file2])
      # TemplateRepo.any_instance.stub(:files).and_return([file1, file2])
      TemplateBuilder.stub(:create).and_return(template)
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
  end

  describe '.load_templates_from_all_repos' do

    let(:fake_repo) { double('fake_repo', load_templates: true) }

    before do
      described_class.stub(:all).and_return([fake_repo])
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

  end

end
