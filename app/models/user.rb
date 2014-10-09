class User < ActiveRecord::Base

  MUTEX = Mutex.new

  has_many :template_repo_providers

  def self.instance
    MUTEX.synchronize do
      User.first || User.create
    end
  end

  def repos
    template_repo_providers.each_with_object({}) do |p, groups|
      (groups[p.name] ||= []).concat(p.repos) if p.respond_to?(:repos)
    end
  end

  def email
    template_repo_providers.each_with_object({}) do |p, groups|
      groups[p.name] = p.email if p.respond_to?(:email)
    end
  end

  def primary_email
    email.values.first
  end

  def username
    template_repo_providers.each_with_object({}) do |provider, memo|
      memo[provider.name] = (provider.username) if provider.respond_to?(:username)
    end
  end

  def subscribe(email=nil)
    email ||= primary_email
    mailchimp_client.create_subscription(email)
  rescue PanamaxAgent::Error
    false
  end

  def update_credentials_for(template_repo_provider, options={})
    template_repo_provider.update(credentials_account: options[:account],
                                  credentials_api_key: options[:api_key] || options[:github_access_token])
    # if the provider credentials are not valid, copy the errors up to the user for display
    template_repo_provider.errors.each { |k, v| errors.add(k, v) }
  end

  private

  def mailchimp_client
    @mailchimp_client ||= PanamaxAgent.mailchimp_client
  end
end
