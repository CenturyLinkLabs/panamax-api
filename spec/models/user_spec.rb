require 'spec_helper'

describe User do
  fixtures :template_repo_providers

  let(:fake_gh_client) { Octokit::Client.new } # see spec_helper

  before do
    subject.template_repo_providers << template_repo_providers(:github)
  end

  it { should respond_to :template_repo_providers }

  describe '.instance' do

    context 'when a user has already been persisted' do

      let(:user) { User.new }

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

  describe "#valid?" do
    before do
      template_repo_providers(:github).stub(:valid?).and_return(false)
    end

    it "returns false if the user's template_repo_providers are not all valid" do
      expect(subject.valid?).to be_false
    end
  end

  describe '#repos' do
    before do
      template_repo_providers(:github).stub(:repos).and_return(['foo/bar', 'bar/foo'])
    end

    it 'returns a hash' do
      expect(subject.repos).to be_a Hash
    end

    it 'returns a hash with keys corresponding to the names of the providers' do
      repo_names = subject.template_repo_providers.collect(&:name)
      expect(subject.repos.keys).to match_array(repo_names)
    end

    it 'returns a hash with values corresponding to the repos of the providers' do
      repos = subject.template_repo_providers.collect(&:repos)
      expect(subject.repos.values).to match_array(repos)
    end

    context 'without any providers' do
      it 'returns an empty hash' do
        subject.stub(:template_repo_providers).and_return([])
        expect(subject.repos).to eq({})
      end
    end
  end

  describe '#email' do

    it 'returns a hash' do
      expect(subject.email).to be_a Hash
    end

    it 'returns a hash with keys corresponding to the names of the providers' do
      repo_names = subject.template_repo_providers.collect(&:name)
      expect(subject.email.keys).to match_array(repo_names)
    end

    it 'returns a hash with values corresponding to the email of the providers' do
      emails = subject.template_repo_providers.collect(&:email)
      expect(subject.email.values).to match_array(emails)
    end

    context 'without any providers' do
      it 'returns an empty hash' do
        subject.stub(:template_repo_providers).and_return([])
        expect(subject.email).to eq({})
      end
    end

  end

  describe '#primary_email' do
    it 'returns the first email address in the hash of emails' do

    end
  end

  describe '#username' do

    it 'returns a hash' do
      expect(subject.username).to be_a Hash
    end

    it 'returns a hash with keys corresponding to the names of the providers' do
      repo_names = subject.template_repo_providers.collect(&:name)
      expect(subject.email.keys).to match_array(repo_names)
    end

    it 'returns a hash with values corresponding to the usernames of the providers' do
      usernames = subject.template_repo_providers.collect(&:username)
      expect(subject.username.values).to match_array(usernames)
    end

    context 'without any providers' do
      it 'returns an empty hash' do
        subject.stub(:template_repo_providers).and_return([])
        expect(subject.email).to eq({})
      end
    end

  end

  describe '#subscribe' do

    let(:mailchimp_client) { double(:mailchimp_client) }

    before do
      mailchimp_client.stub(:create_subscription)
      PanamaxAgent.stub(:mailchimp_client).and_return(mailchimp_client)
    end

    it 'creates a subscription with the mailchimp client' do
      expect(mailchimp_client).to receive(:create_subscription)
        .with(fake_gh_client.emails.first.email)

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

  describe '#update_credentials_for' do
    before do
      fake_gh_client.stub(:scopes).and_return([])
    end

    it 'updates the passed provider with the credentials passed as options' do
      creds = { credentials_account: nil, credentials_api_key: '1234' }
      template_repo_providers(:github).should_receive(:update).with(creds)
      subject.update_credentials_for(template_repo_providers(:github), github_access_token: '1234')
    end

    it 'makes the user not valid if the provider update is not valid' do
      template_repo_providers(:github).stub(:valid?).and_return(false)
      subject.update_credentials_for(template_repo_providers(:github), github_access_token: '1234')
      expect(subject.valid?).to be_false
    end
  end
end
