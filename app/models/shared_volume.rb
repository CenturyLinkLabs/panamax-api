class SharedVolume < ActiveRecord::Base
  self.table_name = 'shared_volumes'

  belongs_to :exported_from_service, class_name: 'Service'

  validates :exported_from_service, uniqueness: { scope: :mounted_on_service_id }, presence: true
  validate :cannot_mount_self

  def exported_from_service_name
    "#{exported_from_service.name}"
  end

  private

  def cannot_mount_self
    if mounted_on_service_id.present? &&
      exported_from_service_id.present? &&
      mounted_on_service_id == exported_from_service_id

      errors.add(:base, "can't mount self")
    end
  end
end
