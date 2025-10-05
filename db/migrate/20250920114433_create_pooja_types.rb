class CreatePoojaTypes < ActiveRecord::Migration[7.2]
  def change
    create_table :pooja_types do |t|
      t.string :name
      t.integer :price
      t.integer :duration
      t.text :description

      t.timestamps
    end
  end
end
