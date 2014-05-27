require 'spec_helper'

describe PanamaxAgent::Github::Client::Repos do
  let(:fake_github_client) { double(:fake_github_client) }
  subject { PanamaxAgent::Github::Client.new(github_client: fake_github_client) }

  let(:repo_name) { 'foo/bar' }
  let(:response) { double(:response) }

  before do
    Octokit::Client.stub(:new).and_return(fake_github_client)
    fake_github_client.stub(:repos).and_return(response)
  end

  describe '#list_repos' do

    it 'returns the repos' do
      expect(fake_github_client).to receive(:repos)
                                    .and_return(response)

      subject.list_repos
    end
  end

  describe '#get_repo' do

    it 'returns the repo' do
      expect(fake_github_client).to receive(:repo)
                                    .with(repo_name)
                                    .and_return(response)

      subject.get_repo(repo_name)
    end
  end

end