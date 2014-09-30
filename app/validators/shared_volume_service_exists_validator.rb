class SharedVolumeServiceExistsValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return unless value.present? && record.respond_to?(:template)
    value.each do |shared_vol|
      next if template_image_names_for(record).include? shared_vol['service']
      record.errors[attribute] << 'service exporting shared volumes must exist'
      break
    end
  end

  def template_image_names_for(model)
    model.template ? model.template.images.map(&:name) : []
  end
end
