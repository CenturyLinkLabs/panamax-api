require 'panamax_agent/client'

module PanamaxAgent
  module Mailchimp
    class Client < PanamaxAgent::Client

      include PanamaxAgent::Mailchimp::Connection

      def create_subscription(email)
        opts = {
          querystring: {
            u: mailchimp_user,
            id: mailchimp_id
          },
          body: {
            'EMAIL' => email
          }
        }

        post('/subscribe/post', opts)
        true
      end
    end
  end
end
