class CreateCustomBookings < ActiveRecord::Migration[7.2]
  def change
    create_table :custom_bookings do |t|
      t.string :user_name, null: false
      t.string :phone, null: false
      t.string :email, null: false
      t.string :gotra
      t.text :seva_description, null: false
      t.date :preferred_date
      t.string :location
      t.string :status, null: false, default: "pending"

      t.timestamps
    end
  end
end
