class ComposeService < ApiModel
  attr_accessor :name, :image, :ports, :links, :expose, :environment, :volumes, :volumes_from, :command
end
