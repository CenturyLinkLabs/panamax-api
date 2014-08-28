class HasUniquePortsValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return unless value.present?
    host_proto_combos = value.map { |port| host_proto_combo(port) }.compact
    host_proto_combos.each do |host_port|
      next unless host_proto_combos.count(host_port) > 1
      record.errors[attribute] << 'host ports must be unique'
      break
    end
  end

  private

  def host_proto_combo(port)
    unless port['host_port'].blank?
      port['host_port'].to_s + port['proto'].to_s
    end
  end
end
