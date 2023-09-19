class RemoveTimersFromGames < ActiveRecord::Migration[7.0]
  def change
    remove_column :games, :tick, :integer
    remove_column :games, :question_tick, :integer
  end
end
