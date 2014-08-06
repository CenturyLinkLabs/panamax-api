class ApiModel
  include ActiveModel::Serialization

  # Override attr_accessor so we can maintain a collection of defined
  # attribues for serialization purposes.
  def self.attr_accessor(*vars)
    @attributes ||= []
    @attributes += vars
    super(*vars)
  end

  def self.attributes
    @attributes
  end

  def initialize(attrs={})
    attrs.each do |attr, value|
      self.public_send("#{attr}=", value)
    end if attrs
  end

  # Required by ActiveModel::Serialization to support as_json
  def attributes
    self.class.attributes
  end
end
