require 'spec_helper'

describe PanamaxAgent::Github::Client::Repos do
  let(:fake_github_client) { double(:fake_github_client) }
  subject { PanamaxAgent::Github::Client.new(github_client: fake_github_client) }

  let(:repo_name)   { 'foo/bar' }
  let(:file_path)   { 'my_file.txt' }
  let(:commit_msg)  { 'Some commit message.' }
  let(:file)        { fixture_data('foo.txt') }
  let(:response)    { double(:response, sha: '123123sdfsf234234') }

  before do
    Octokit::Client.stub(:new).and_return(fake_github_client)
    fake_github_client.stub(:contents).and_return(response)
  end

  describe '#create_file' do

    it 'create a file' do
      expect(fake_github_client).to receive(:create_contents)
                                    .with(repo_name, file_path, commit_msg, nil, file: file)
                                    .and_return(response)

      subject.create_file(repo_name, file_path, commit_msg, file)
    end
  end

  describe '#get_file' do

    it 'get a file' do
      expect(fake_github_client).to receive(:contents)
                                    .with(repo_name, path: file_path)
                                    .and_return(response)

      subject.get_file(repo_name, file_path)
    end
  end

  describe '#update_file' do

    it 'update a file' do
      expect(fake_github_client).to receive(:update_contents)
                                    .with(repo_name, file_path, commit_msg, response.sha, nil, file: file)
                                    .and_return(response)
      subject.update_file(repo_name, file_path, commit_msg, file)
    end
  end

  describe '#delete_file' do

    it 'delete a file' do
      expect(fake_github_client).to receive(:delete_contents)
                                    .with(repo_name, file_path, commit_msg, response.sha, {})
                                    .and_return(response)
      subject.delete_file(repo_name, file_path, commit_msg)
    end
  end

end