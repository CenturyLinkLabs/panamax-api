class HasContainerNamesValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return unless value.present?
    value.each do |vol_from|
      next if vol_from['container_name'].present?
      record.errors[attribute] << "container name can't be blank"
      break
    end
  end
end
