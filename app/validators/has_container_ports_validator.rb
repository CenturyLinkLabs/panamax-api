class HasContainerPortsValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return unless value.present?
    value.each do |port|
      next if port['container_port'].present?
      record.errors[attribute] << "container port can't be blank"
      break
    end
  end
end
