class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :github_access_token
    end
  end
end
