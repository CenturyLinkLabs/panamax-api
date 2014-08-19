class IsNumericListValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    value.each do |port|
      unless port.to_s =~ /\A[+-]?\d+\Z/
        record.errors.add(attribute, 'list can only contain numbers')
        break
      end
    end
  end
end
