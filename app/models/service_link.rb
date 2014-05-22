class ServiceLink < ActiveRecord::Base
  belongs_to :linked_to_service, class_name: 'Service'

  validates :linked_to_service_id, uniqueness: { scope: :linked_from_service_id }
  validates :alias, presence: true

  def link_string
    "#{linked_to_service.name}:#{self.alias}"
  end
end
