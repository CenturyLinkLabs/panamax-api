class HasLinkAliasValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return unless value.present?
    catch(:done) do
      value.each do |link|
        unless link['alias'].present?
          record.errors[attribute] << "link alias can't be blank"
          throw :done
        end
      end
    end
  end
end
