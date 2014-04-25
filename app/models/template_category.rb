class TemplateCategory < ActiveRecord::Base
  belongs_to :template

  validates :name, uniqueness: { scope: :template_id }
end
