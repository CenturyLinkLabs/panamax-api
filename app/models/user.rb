class User < ActiveRecord::Base

  EMAIL_SCOPES = %w(user user:email)

  validate :access_token_scope, on: :update

  def self.instance
    User.first || User.create
  end

  def repos
    retrieve_from_github(:repos, []) do |repos|
      repos.map(&:full_name)
    end
  end

  def github_username
    retrieve_from_github(:user) do |user|
      user.login
    end
  end

  def email
    retrieve_from_github(:emails) do |emails|
      emails.find(&:primary).email
    end
  end

  private

  def retrieve_from_github(resource, default=nil)
    result = github_client.send(resource)
    block_given? ? yield(result) : result
  rescue Octokit::Unauthorized
    default
  end

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
    @github_client ||= Octokit::Client.new(access_token: github_access_token)
  end
end
