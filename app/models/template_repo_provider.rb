class TemplateRepoProvider < ActiveRecord::Base

  belongs_to :user

  def credentials
    TemplateRepoProviderCredentials.new(credentials_account, credentials_api_key)
  end

  def credentials=(credentials)
    self[:credentials_account] = credentials.account
    self[:credentials_api_key] = credentials.api_key
    @credentials = credentials
  end

  def self.find_or_create_default_for(user)
    user.template_repo_providers.find_or_create_by(name: GithubTemplateRepoProvider::DEFAULT_NAME,
                                                   type: 'GithubTemplateRepoProvider')
  end

end
