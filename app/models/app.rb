class App < ActiveRecord::Base
  has_many :services

  def self.create_from_template(t)
    self.create(name: t.name, from: "Template: #{t.name}")
  end
end