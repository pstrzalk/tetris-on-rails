class AddFlags < ActiveRecord::Migration[7.0]
  def change
    create_table :flags do |t|
      t.string :key, null: false
    end
  end
end
