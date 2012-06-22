class ChangePsswdToBinary < ActiveRecord::Migration
  def up
    create_table "users", :force => true do |t|
      t.string "name"
      t.string "instance_url"
      t.string "identity_url"
      t.string "client_id"
      t.string "user_name"
      t.string "password"
      t.string "crypted_password"
      t.string "login_url"
      t.string "organization_id"
      t.string "user_id"
      t.string "email"
      t.string "profile_thumbnail_url"
      t.string "first_name"
      t.string "last_name"
      t.binary "refresh_token"
      t.binary "access_token"
    end
  end

  def down
  end
end
