class User < ActiveRecord::Base

  def self.instance
    User.first || User.create
  end
end
