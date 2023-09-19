class AddNextBrickShapeToGames < ActiveRecord::Migration[7.0]
  def change
    add_column :games, :next_brick_shape, :string, default: nil
  end
end
