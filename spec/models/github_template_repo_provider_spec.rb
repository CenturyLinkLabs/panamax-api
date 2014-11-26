require 'spec_helper'

describe GithubTemplateRepoProvider do

  let(:fake_gh_client) { Octokit::Client.new }
  before do
    subject.stub(:github_client).and_return(fake_gh_client)
  end

  describe 'access token validations' do

    it 'does not validate the access token on new instances' do
      expect(User.new).to be_valid
    end

    context 'when the access token has "user" scope' do

      before do

        fake_gh_client.stub(:scopes).and_return(['user'])
        subject.update(credentials_api_key: 'token')
      end

      it { should be_valid }
    end

    context 'when the access token has "user:email" scope' do

      before do
        fake_gh_client.stub(:scopes).and_return(['user:email'])
        subject.update(credentials_api_key: 'token')
      end

      it { should be_valid }
    end

    context 'when the access token has none of the required scopes' do

      before do
        fake_gh_client.stub(:scopes).and_return(['foo'])
        subject.update(credentials_api_key: 'token')
        subject.valid?
      end

      it { should_not be_valid }

      it 'returns a "token too restrictive" message' do
        expect(subject.errors[:credentials_api_key]).to include('token too restrictive')
      end
    end

    context 'when the access token is no good at all' do

      before do
        fake_gh_client.stub(:scopes)
        .and_raise(Octokit::Unauthorized)
        subject.update(credentials_api_key: 'token')
        subject.valid?
      end

      it { should_not be_valid }

      it 'returns an "invalid token" message' do
        expect(subject.errors[:credentials_api_key]).to include('invalid token')
      end
    end
  end

  describe 'after initialization hook' do
    it 'sets the name of the object' do
      expect(described_class.new.name).to eq GithubTemplateRepoProvider::DEFAULT_NAME
    end
  end

  describe '#repos' do
    let(:repo) { double(:repo, full_name: 'foo/bar') }

    context 'when the github token is valid' do

      before do
        fake_gh_client.stub(:repos).and_return([repo])
      end

      it 'returns a list of repo full names' do
        expect(subject.repos).to include(repo.full_name)
      end
    end

    context 'when the github token is invalid' do

      before do
        fake_gh_client.stub(:repos)
          .and_raise(Octokit::Unauthorized)
      end

      it 'returns an empty list' do
        expect(subject.repos).to eq []
      end
    end
  end

  describe '#username' do
    context 'when the github token is valid' do

      let(:gh_user_object) { double(:gh_user_object, login: 'testuser') }

      before do
        fake_gh_client.stub(:user).and_return(gh_user_object)
      end

      it 'returns the username retrieved from github' do
        expect(subject.username).to eq 'testuser'
      end
    end

    context 'when the github token is invalid' do

      before do
        fake_gh_client.stub(:user)
        .and_raise(Octokit::Unauthorized)
      end

      it 'returns nil' do
        expect(subject.username).to be_nil
      end
    end
  end

  describe '#email' do
    context 'when the github token is valid' do

      let(:gh_email1) do
        double(:gh_email_object, email: 'foo@bar.com', primary: false)
      end
      let(:gh_email2) do
        double(:gh_email_object, email: 'bar@foo.com', primary: true)
      end

      before do
        fake_gh_client.stub(:emails)
        .and_return([gh_email1, gh_email2])
      end

      it 'returns the primary email retrieved from github' do
        expect(subject.email).to eq gh_email2.email
      end
    end

    context 'when the github token is invalid' do

      before do
        fake_gh_client.stub(:emails)
        .and_raise(Octokit::Unauthorized)
      end

      it 'returns nil' do
        expect(subject.email).to be_nil
      end
    end

    context 'when the github token is unscoped for email' do

      before do
        fake_gh_client.stub(:emails)
        .and_raise(Octokit::NotFound)
      end

      it 'returns nil' do
        expect(subject.email).to be_nil
      end
    end

  end

  describe '#files_for' do
    let(:template_repo) { double(:template_repo, name: 'template/repo') }

    before do
      file_path = File.expand_path('../support/fixtures/sample.tar.gz', __dir__)
      file = File.open(file_path)
      subject.stub(:open).and_return(file)
    end

    it 'returns an array of objects that respond to :name and :content' do
      file = subject.files_for(template_repo).first
      expect(file).to respond_to(:name)
      expect(file).to respond_to(:content)
    end

    it 'returns files contained in the archive' do
      file_names = subject.files_for(template_repo).map(&:name)
      expect(file_names).to include 'sample/rails.pmx'
      expect(file_names).to include 'sample/README.md'
    end

    it 'excludes directories contained in the archive' do
      file_names = subject.files_for(template_repo).map(&:name)
      expect(file_names).to_not include 'sample/'
    end
  end

  describe '#save_template' do
    fixtures :templates
    let(:template) { Template.first }
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
      fake_gh_client.stub(:create_contents)
      fake_gh_client.stub(:update_contents)
      fake_gh_client.stub(:contents)
    end

    context 'when template file is saved to the repo' do
      it 'invokes create_contents on the github client' do
        expect(fake_gh_client).to receive(:create_contents)
                                  .with(
                                      'bob/repo',
                                      "#{template.name}.pmx",
                                      "Saved a Panamax template #{template.name}.pmx",
                                      TemplateFileSerializer.new(template).to_yaml,
                                      {}
                                  )
        subject.save_template(template, params)
      end
    end

    context 'when template file is saved again to the repo' do
      before do
        fake_gh_client.stub(:create_contents).and_raise(Octokit::UnprocessableEntity)
        fake_gh_client.stub(:contents).and_return(contents_response)
      end
      it 'invokes update_contents on the github client' do
        expect(fake_gh_client).to receive(:contents)
                                 .with('bob/repo', path: "#{template.name}.pmx")
                                 .and_return(contents_response)
                                 .ordered
        expect(fake_gh_client).to receive(:update_contents)
                                 .with(
                                     'bob/repo',
                                     "#{template.name}.pmx",
                                     "Saved a Panamax template #{template.name}.pmx",
                                     contents_response.sha,
                                     TemplateFileSerializer.new(template).to_yaml,
                                     {}
                                 )
                                 .ordered
        subject.save_template(template, params)
      end
    end

    context 'when template file is saved to the repo with a file name' do

      it 'invokes create_contents on the github client' do
        expect(fake_gh_client).to receive(:create_contents)
                                 .with(
                                     'bob/repo',
                                     'somefile.pmx',
                                     'Saved a Panamax template somefile.pmx',
                                     TemplateFileSerializer.new(template).to_yaml,
                                     {}
                                 )
        subject.save_template(template, params_with_file_name)
      end
    end

    context 'when template file cannot be updated to the repo' do
      before do
        fake_gh_client.stub(:create_contents).and_raise(Octokit::UnprocessableEntity)
        fake_gh_client.stub(:contents).and_raise(Octokit::NotFound)
      end
      it 'should raise an error' do
        expect { subject.save_template(template, params) }.to raise_error
      end
    end

    context 'when user does not have an auth token' do
      before do
        subject.stub(:github_client).and_return(nil)
      end

      it 'should raise an error' do
        expect { subject.save_template(template, params) }.to raise_error
      end
    end

    context 'when repo does not exist' do
      before do
        fake_gh_client.stub(:create_contents).and_raise(Octokit::NotFound)
      end

      it 'should raise an error' do
        expect { subject.save_template(template, params) }.to raise_error
      end
    end

  end

  describe "#retrieve_from_github" do

    let(:gh_user_object) { double(:gh_user_object, login: 'testuser') }

    before do
      fake_gh_client.stub(:user).and_return(gh_user_object)
    end

    it "only calls out to github for a specific resource once (memoized results) " do
      fake_gh_client.should_receive(:user).at_most(:once)
      subject.username
      subject.username
    end

  end

end
