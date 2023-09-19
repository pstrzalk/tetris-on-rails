class AddNicknameToGames < ActiveRecord::Migration[7.0]
  def change
    add_column :games, :nickname, :string, default: nil
  end
end
