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

  describe 'after_destroy callback' do
    it 'destroys all templates in the db sourced from that repo' do
      template_repos(:repo1).destroy
      expect(Template.where(source: template_repos(:repo1).name).count).to eq 0
    end
  end
end
