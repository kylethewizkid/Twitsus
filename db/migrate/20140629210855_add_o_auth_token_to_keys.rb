class AddOAuthTokenToKeys < ActiveRecord::Migration
  def change
    add_column :keys, :oauth_token, :string
  end
end
