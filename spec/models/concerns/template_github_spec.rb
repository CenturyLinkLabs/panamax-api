require 'spec_helper'

describe TemplateGithub do

  subject { Template.first }

  describe 'class methods' do

    subject do
      Class.new do
        include TemplateGithub
      end
    end

    describe '.load_templates_from_template_repo' do

      let(:template_repo) { template_repos(:repo1) }
      let(:template) { Template.new }
      let(:file1) { double(:file, name: 'readme', content: 'hi') }
      let(:file2) { double(:file, name: 'foo.pmx', content: 'bar') }

      before do
        TemplateRepo.any_instance.stub(:files).and_return([file1, file2])
        TemplateBuilder.stub(:create).and_return(template)
      end

      it 'invokes the TemplateBuilder ONLY for .pmx files' do
        expect(TemplateBuilder).to receive(:create).once
        subject.load_templates_from_template_repo(template_repo)
      end

      it 'invokes the TemplateBuilder with .pmx file contents' do
        expect(TemplateBuilder).to receive(:create).with(file2.content)
        subject.load_templates_from_template_repo(template_repo)
      end

      it 'sets the repo name on the source field of the template' do
        subject.load_templates_from_template_repo(template_repo)
        expect(template.source).to eql template_repo.name
      end
    end

    describe '.load_templates_from_template_repos' do

      before do
        subject.stub(:load_templates_from_template_repo)
      end

      it 'invokes load_template_from_template_repo for each repo' do
        expect(subject).to receive(:load_templates_from_template_repo)
          .once
          .with(template_repos(:repo1))

        expect(subject).to receive(:load_templates_from_template_repo)
          .once
          .with(template_repos(:repo2))

        subject.load_templates_from_template_repos
      end
    end

  end

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
           TemplateFileSerializer.new(subject).to_yaml,
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
            TemplateFileSerializer.new(subject).to_yaml,
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
            TemplateFileSerializer.new(subject).to_yaml,
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

    context 'when repo does not exist' do
      before do
        github_client.stub(:create_contents).and_raise(Octokit::NotFound)
      end

      it 'should raise an error' do
        expect { subject.save_to_repo(params) }.to raise_error
      end
    end
  end
end
