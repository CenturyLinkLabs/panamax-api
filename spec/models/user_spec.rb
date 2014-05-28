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
end
