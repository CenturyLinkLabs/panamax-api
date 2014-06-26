module Classifiable
  extend ActiveSupport::Concern

  VALID_TYPES = PanamaxApi::TYPES.map { |type| type['name'].downcase }
  DEFAULT_TYPE = PanamaxApi::TYPES.find { |type| type['default'] }['name']

  included do
    before_validation :clean_type
  end

  private

  def clean_type
    return if type.present? && VALID_TYPES.include?(type.downcase)
    self.type = DEFAULT_TYPE
  end

end
