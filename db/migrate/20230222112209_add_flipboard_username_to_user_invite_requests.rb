class AddFlipboardUsernameToUserInviteRequests < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  def change
    add_column :user_invite_requests, :flipboard_username, :string
    add_index :user_invite_requests, :flipboard_username, algorithm: :concurrently
  end
end
