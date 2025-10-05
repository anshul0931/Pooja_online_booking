class CreatePujas < ActiveRecord::Migration[7.2]
  def change
    create_table :pujas do |t|
      t.references :temple, null: false, foreign_key: true
      t.string :title
      t.text :description
      t.integer :duration_minutes
      t.decimal :base_price

      t.timestamps
    end
  end
end
