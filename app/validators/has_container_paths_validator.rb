class HasContainerPathsValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return unless value.present?
    value.each do |volume|
      next if volume['container_path'].present?
      record.errors[attribute] << "container path and host path can't be blank"
      break
    end
  end
end
