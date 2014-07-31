require 'spec_helper'

describe GithubAccessTokenOverride do

  using GithubAccessTokenOverride

  subject { User.new }

  describe '#github_access_token' do

    it 'returns our hard-coded access token' do
      expect(subject.github_access_token).to eq '4afd3519b925cd38bb1b04398de783266859ca47'
    end
  end
end
