require 'spec_helper'

describe User do
  let(:fake_gh_client) { double(:fake_gh_client) }

  before do
    Octokit::Client.stub(:new).and_return(fake_gh_client)
  end

  it { should respond_to :github_access_token }

  describe '.instance' do

    context 'when a user has already been persisted' do

      let(:user) { User.new(github_access_token: 'foo') }

      before do
        user.save
      end

      it 'does not persist a new user' do
        expect { User.instance }.to_not change(User, :count)
      end

      it 'returns the user' do
        expect(User.instance).to eq user
      end
    end

    context 'when a user has NOT already been persisted' do

      it 'persists a new user' do
        expect { User.instance }.to change(User, :count).by(1)
      end

      it 'returns the user' do
        expect(User.instance).to be_instance_of(User)
      end
    end
  end

  describe 'access token validations' do

    it 'does not validate the access token on new instances' do
      expect(User.new).to be_valid
    end

    context 'when the access token has "user" scope' do

      before do
        fake_gh_client.stub(:scopes).and_return(['user'])
        subject.update(github_access_token: 'token')
      end

      it { should be_valid }
      it { should have(:no).error_on(:github_access_token) }
    end

    context 'when the access token has "user:email" scope' do

      before do
        fake_gh_client.stub(:scopes).and_return(['user:email'])
        subject.update(github_access_token: 'token')
      end

      it { should be_valid }
      it { should have(:no).error_on(:github_access_token) }
    end

    context 'when the access token has none of the required scopes' do

      before do
        fake_gh_client.stub(:scopes).and_return(['foo'])
        subject.update(github_access_token: 'token')
      end

      it { should_not be_valid }
      it { should have(1).error_on(:github_access_token) }

      it 'returns a "token too restrictive" message' do
        expect(subject.errors_on(:github_access_token)).to include(
          'token too restrictive')
      end
    end

    context 'when the access token is no good at all' do

      before do
        fake_gh_client.stub(:scopes)
          .and_raise(Octokit::Unauthorized)
        subject.update(github_access_token: 'token')
      end

      it { should_not be_valid }
      it { should have(1).error_on(:github_access_token) }

      it 'returns an "invalid token" message' do
        expect(subject.errors_on(:github_access_token)).to include(
          'invalid token')
      end
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

  describe '#github_username' do
    context 'when the github token is valid' do

      let(:gh_user_object) { double(:gh_user_object, login: 'testuser') }

      before do
        fake_gh_client.stub(:user).and_return(gh_user_object)
      end

      it 'returns the username retrieved from github' do
        expect(subject.github_username).to eq 'testuser'
      end
    end

    context 'when the github token is invalid' do

      before do
        fake_gh_client.stub(:user)
          .and_raise(Octokit::Unauthorized)
      end

      it 'returns nil' do
        expect(subject.github_username).to be_nil
      end
    end
  end

  describe '#subscribe' do

    let(:mailchimp_client) { double(:mailchimp_client) }

    let(:gh_email) do
      double(:gh_email_object, email: 'bar@foo.com', primary: true)
    end

    before do
      fake_gh_client.stub(:emails).and_return([gh_email])

      mailchimp_client.stub(:create_subscription)
      PanamaxAgent.stub(:mailchimp_client).and_return(mailchimp_client)
    end

    it 'creates a subscription with the mailchimp client' do
      expect(mailchimp_client).to receive(:create_subscription)
        .with(gh_email.email)

      subject.subscribe
    end

    context 'when an error is raised' do

      before do
        mailchimp_client.stub(:create_subscription)
          .and_raise(PanamaxAgent::Error, 'boom')
      end

      it 'returns false' do
        expect(subject.subscribe).to eq false
      end
    end
  end
end
