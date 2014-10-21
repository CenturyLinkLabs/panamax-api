class UserSerializer < ActiveModel::Serializer
  self.root = false

  GROUPED_ATTRS = %i(email repos username)

  attributes *GROUPED_ATTRS

  has_many :template_repo_providers, serializer: TemplateRepoProviderSerializer

  # return a flattened or singular response if there's only one template repo provider
  # in the grouped hash of values from the User model for these attributes
  GROUPED_ATTRS.each do |attr|
    define_method attr do
      hsh = object.send(attr)
      hsh.keys.length == 1 ? hsh.values.first : hsh if hsh.present?
    end
  end

  def filter(keys)
    if github_repo_provider
      keys + [:github_access_token_present, :github_username]
    else
      keys
    end
  end

  def github_access_token_present
    github_repo_provider.credentials.api_key.present?
  end

  def github_username
    github_repo_provider.username
  end

  private

  def github_repo_provider
    @github_repo_provider ||= object.template_repo_providers.find do |provider|
      provider.type == 'GithubTemplateRepoProvider'
    end
  end

end
