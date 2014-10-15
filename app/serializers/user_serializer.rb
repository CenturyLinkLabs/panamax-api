class UserSerializer < ActiveModel::Serializer
  self.root = false

  attributes :email, :repos, :github_access_token_present, :github_username

  def github_access_token_present
    object.github_access_token.present?
  end
end
