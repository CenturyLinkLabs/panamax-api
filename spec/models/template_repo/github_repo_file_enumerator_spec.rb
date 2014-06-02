require 'spec_helper'

describe TemplateRepo::GithubRepoFileEnumerator do

  subject { TemplateRepo::GithubRepoFileEnumerator.new('foo/bar') }

  describe '#each' do

    let(:github_client) { double(:github_client) }
    let(:tree) { double(:tree) }
    let(:blob_node) do
      double(:blob_node, type: 'blob', path: 't.pmx', size: '2', sha: 'a1b')
    end
    let(:content) { 'Hi' }

    before do
      ref = double(:ref)
      ref.stub_chain(:object, :sha).and_return('abc')
      github_client.stub(:ref).and_return(ref)

      commit = double(:commit)
      commit.stub_chain(:commit, :tree, :sha).and_return('123')
      github_client.stub(:commit).and_return(commit)

      tree.stub(:tree).and_return([blob_node, blob_node])
      github_client.stub(:tree).and_return(tree)

      blob = double(:blob)
      blob.stub(:content).and_return(Base64.encode64(content))
      github_client.stub(:blob).and_return(blob)

      Octokit::Client.stub(:new).and_return(github_client)
    end

    it 'yields once for each blob node in the tree' do
      expect { |b| subject.each(&b) }.to yield_control.twice
    end

    it 'yields something w/ a name, size and content' do

      result = subject.first  # Note: this uses each under the covers

      expect(result).to respond_to :name
      expect(result.name).to eq blob_node.path
      expect(result).to respond_to :size
      expect(result.size).to eq blob_node.size
      expect(result).to respond_to :content
      expect(result.content).to eq content

      expect(result.inspect).to include blob_node.path
    end

    context 'when the tree contains non-blob nodes' do

      let(:tree_node) { double(:tree_node, type: 'tree') }

      before do
        tree.stub(:tree).and_return([tree_node, blob_node])
      end

      it 'yields only for the blob node' do
        expect { |b| subject.each(&b) }.to yield_control.once
      end
    end
  end

end
