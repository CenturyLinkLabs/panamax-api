class HasEnvironmentVariableValuesValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return unless value.present?
    value.each do |var|
      next if var['value'].present?
      record.errors[attribute] << "environment variable values can't be blank"
      break
    end
  end
end
