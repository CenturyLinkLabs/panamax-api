class HasContainerPortsValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return unless value.present?
    catch(:done) do
      value.each do |port|
        unless port['container_port'].present?
          record.errors[attribute] << "container port can't be blank"
          throw :done
        end
      end
    end
  end
end
