class HasVolumePathsValidator < ActiveModel::EachValidator

  def validate_each(record, attribute, value)
    return unless value.present?

    catch(:done) do
      value.each do |volume|
        unless volume['container_path'].present? && volume['host_path'].present?
          record.errors[attribute] << "container path and host path can't be blank"
          throw :done
        end
      end
    end
  end

end
