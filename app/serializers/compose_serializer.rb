class ComposeSerializer < ActiveModel::Serializer

  attributes :name
  has_many :services

  def to_yaml
    as_json.deep_stringify_keys.to_yaml
  end

end
