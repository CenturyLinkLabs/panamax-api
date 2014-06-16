require 'spec_helper'

describe PanamaxAgent::Mailchimp::Client do

  subject { PanamaxAgent::Mailchimp::Client.new }

  let(:response) { double(:response) }

  describe '#create_subscription' do

    let(:email) { 'foo@bar.com' }

    before do
      subject.stub(post: response)
    end

    it 'POSTs the email address to MailChimp' do
      opts = {
        querystring: {
          u: subject.mailchimp_user,
          id: subject.mailchimp_id
        },
        body: {
          'EMAIL' => email
        }
      }

      expect(subject).to receive(:post)
        .with('/subscribe/post', opts)
        .and_return(response)

      subject.create_subscription(email)
    end

    it 'returns true' do
      expect(subject.create_subscription(email)).to eq true
    end
  end
end
