class AddTimers < ActiveRecord::Migration[7.0]
  def change
    create_table :timers do |t|
      t.references :game

      t.integer :tick, default: 0, null: false
      t.integer :question_tick, default: 0
    end
  end
end
