require 'spec_helper'

describe TemplateGithub do

  subject { Template.first }

  describe '#save_to_repo' do

    let(:github_client) { double(:github_client) }
    let(:contents_response) { double(:contents_response, sha: 'ccccccc') }
    let(:params) do
      {
        repo: 'bob/repo'
      }
    end
    let(:params_with_file_name) do
      {
        repo: 'bob/repo',
        file_name: 'somefile'
      }
    end

    before do
      Octokit::Client.stub(:new).and_return(github_client)
      github_client.stub(:create_contents)
      github_client.stub(:update_contents)
      github_client.stub(:contents)
    end

    context 'when template file is saved to the repo' do
      it 'invokes create_contents on the github client' do
        expect(github_client).to receive(:create_contents)
                                 .with(
                                   'bob/repo',
                                   "#{subject.name}.pmx",
                                   "Saved a Panamax template #{subject.name}.pmx",
                                   subject.as_json.to_s,
                                   {}
                                 )
        subject.save_to_repo(params)
      end
    end

    context 'when template file is saved again to the repo' do
      before do
        github_client.stub(:create_contents).and_raise(Octokit::UnprocessableEntity)
        github_client.stub(:contents).and_return(contents_response)
      end
      it 'invokes update_contents on the github client' do
        expect(github_client).to receive(:contents)
                                 .with('bob/repo', path: "#{subject.name}.pmx")
                                 .and_return(contents_response)
                                 .ordered
        expect(github_client).to receive(:update_contents)
                                 .with(
                                   'bob/repo',
                                   "#{subject.name}.pmx",
                                   "Saved a Panamax template #{subject.name}.pmx",
                                   contents_response.sha,
                                   subject.as_json.to_s,
                                   {}
                                 )
                                 .ordered
        subject.save_to_repo(params)
      end
    end

    context 'when template file is saved to the repo with a file name' do
      it 'invokes create_contents on the github client' do
        expect(github_client).to receive(:create_contents)
                                 .with(
                                   'bob/repo',
                                   'somefile.pmx',
                                   'Saved a Panamax template somefile.pmx',
                                   subject.as_json.to_s,
                                   {}
                                 )
        subject.save_to_repo(params_with_file_name)
      end
    end

    context 'when template file cannot be updated to the repo' do
      before do
        github_client.stub(:create_contents).and_raise(Octokit::UnprocessableEntity)
        github_client.stub(:contents).and_raise(Octokit::NotFound)
      end
      it 'should raise an error' do
        expect { subject.save_to_repo(params) }.to raise_error
      end
    end

    context 'when user does not have an auth token' do
      before do
        Octokit::Client.stub(:new).and_return(nil)
      end

      it 'should raise an error' do
        expect { subject.save_to_repo(params) }.to raise_error
      end
    end

  end
end
