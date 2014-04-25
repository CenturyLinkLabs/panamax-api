class ServiceLink < ActiveRecord::Base
  belongs_to :linked_to_service, class_name: 'Service'

  def link_string
    "#{linked_to_service.name}:#{self.alias}"
  end
end
