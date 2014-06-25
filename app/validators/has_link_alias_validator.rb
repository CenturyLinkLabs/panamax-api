class HasLinkAliasValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return unless value.present?
    value.each do |link|
      next if link['alias'].present?
      record.errors[attribute] << "link alias can't be blank"
      break
    end
  end
end
