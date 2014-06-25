class ServiceLinkExistsValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return unless value.present? && record.respond_to?(:template)
    value.each do |link|
      next if template_image_names_for(record).include? link['service']
      record.errors[attribute] << 'linked service must exist'
      break
    end
  end

  def template_image_names_for(model)
    model.template ? model.template.images.map(&:name) : []
  end
end
