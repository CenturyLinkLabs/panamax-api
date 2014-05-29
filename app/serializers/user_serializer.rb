class UserSerializer < ActiveModel::Serializer
  self.root = false

  attributes :repos
end
