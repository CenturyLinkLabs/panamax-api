class Status < ApiModel
  attr_accessor :overall, :services

  def initialize(attrs={}, persisted=false)
    super attrs
  end
end
