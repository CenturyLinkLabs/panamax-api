require 'panamax_agent/client'
require 'panamax_agent/github/client/repos'
require 'panamax_agent/github/client/file'

module PanamaxAgent
  module Github
    class Client < PanamaxAgent::Client

      attr_reader :github_client

      def initialize(options={})
        super
        @github_client = Octokit::Client.new(access_token: github_access_token)
      end

      def token_authenticated?
        @github_client.token_authenticated?
      end

      def scopes
        @github_client.scopes
      end

      def emails
        @github_client.emails
      end

      include PanamaxAgent::Github::Client::Repos
      include PanamaxAgent::Github::Client::File

    end
  end
end
