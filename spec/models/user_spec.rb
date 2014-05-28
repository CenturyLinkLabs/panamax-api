require 'spec_helper'

describe User do
  it { should respond_to :email }
  it { should respond_to :github_access_token }

  describe '.instance' do

    context 'when a user has already been persisted' do

      let(:user) { User.new(email: 'user@centurylink.com') }

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
        Octokit::Client.any_instance.stub(:scopes).and_return(['user'])
        subject.update(github_access_token: 'token')
      end

      it { should be_valid }
      it { should have(:no).error_on(:github_access_token) }
    end

    context 'when the access token has "user:email" scope' do

      before do
        Octokit::Client.any_instance.stub(:scopes).and_return(['user:email'])
        subject.update(github_access_token: 'token')
      end

      it { should be_valid }
      it { should have(:no).error_on(:github_access_token) }
    end

    context 'when the access token has none of the required scopes' do

      before do
        Octokit::Client.any_instance.stub(:scopes).and_return(['foo'])
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
        Octokit::Client.any_instance.stub(:scopes)
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
end
