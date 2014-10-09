class RemoveGithubAccessTokenFromUsers < ActiveRecord::Migration

  def up
    if user = User.first
      access_token = user.github_access_token
      user_default_provider = TemplateRepoProvider.find_or_create_default_for(user)
      user_default_provider.update_attribute(:credentials_api_key, access_token)
    end
    remove_column :users, :github_access_token, :string
  end

  def down
    add_column :users, :github_access_token, :string
    if user = User.first
      user_default_provider = user.template_repo_providers.find_by(name: GithubTemplateRepoProvider::DEFAULT_NAME,
                                                                   type: 'GithubTemplateRepoProvider')
      user.update_attribute(:github_access_token, user_default_provider.credentials_api_key) if user_default_provider
    end
  end
end
