class ServiceLink < ActiveRecord::Base
  belongs_to :linked_to_service, class_name: 'Service'

  validates :linked_to_service_id, uniqueness: { scope: :linked_from_service_id }
  validates :alias, presence: true
  validate :cannot_link_to_self

  def link_string
    "#{linked_to_service.name}:#{self.alias}"
  end

  private

  def cannot_link_to_self
    if linked_to_service_id.present? &&
      linked_from_service_id.present? &&
      linked_to_service_id == linked_from_service_id

      errors.add(:base, "can't link to self")
    end
  end
end
