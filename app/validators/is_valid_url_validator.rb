class IsValidUrlValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)

    begin
      endpoint = URI.parse(value)
    rescue URI::Error
      record.errors.add(attribute, 'Malformed URI')
      return false
    end

    unless endpoint.scheme
      record.errors.add(attribute, 'Please specify either http or https')
    end

    unless endpoint.host
      record.errors.add(attribute, 'Endpoint is invalid')
    end
  end
end
