class CreateTemples < ActiveRecord::Migration[7.2]
  def change
    create_table :temples do |t|
      t.string :name
      t.string :address
      t.string :city
      t.text :description

      t.timestamps
    end
  end
end
