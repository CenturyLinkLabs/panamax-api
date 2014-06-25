class HasUniquePortsValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return unless value.present?
    host_ports = value.map { |port| port['host_port'] }.compact
    host_ports.each do |host_port|
      next unless host_ports.count(host_port) > 1
      record.errors[attribute] << 'host ports must be unique'
      break
    end
  end
end
