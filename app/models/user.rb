class User < ActiveRecord::Base

  EMAIL_SCOPES = %w(user user:email)

  validate :access_token_scope, on: :update

  def self.instance
    User.first || User.create
  end

  def repos
    github_client.repos.map(&:full_name)
  rescue Octokit::Unauthorized
    []
  end

  private

  def access_token_scope
    unless access_token_scoped_for_email?
      errors.add(:github_access_token, 'token too restrictive')
    end
  rescue Octokit::Unauthorized
    errors.add(:github_access_token, 'invalid token')
  end

  def access_token_scoped_for_email?
    (github_client.scopes & EMAIL_SCOPES).any?
  end

  def github_client
    Octokit::Client.new(access_token: github_access_token)
  end
end
