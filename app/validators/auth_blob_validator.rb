class AuthBlobValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    parts = Base64.decode64(value.to_s).split('|')
    record.errors[attribute] << "Invalid Token" unless parts.length == 4
  end
end
