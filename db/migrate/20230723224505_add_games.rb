class AddGames < ActiveRecord::Migration[7.0]
  def change
    create_table :games do |t|
      t.uuid :player_id
      t.integer :score, default: 0, null: false
      t.boolean :running, default: true
      t.text :board, array: true
      t.text :actions, array: true

      t.string :email, default: nil

      t.string :brick_shape, default: nil, null: true
      t.integer :brick_rotated_times, default: nil, null: true
      t.integer :brick_position_x, default: nil, null: true
      t.integer :brick_position_y, default: nil, null: true

      t.string :question_id, default: nil, null: true
      t.string :question_result, default: nil, null: true

      t.timestamps
    end
  end
end
