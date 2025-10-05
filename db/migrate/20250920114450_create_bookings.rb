class CreateBookings < ActiveRecord::Migration[7.2]
  def change
    create_table :bookings do |t|
      t.references :pooja_type, null: false, foreign_key: true
      t.string :user_name
      t.string :phone
      t.string :email
      t.boolean :samagri_required
      t.string :package
      t.string :status
      t.text :notes
      t.string :location

      t.timestamps
    end
  end
end
