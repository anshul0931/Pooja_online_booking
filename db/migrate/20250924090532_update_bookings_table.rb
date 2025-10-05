class UpdateBookingsTable < ActiveRecord::Migration[7.1]
  def change
    add_column :bookings, :booking_date, :date
    add_column :bookings, :customer_type, :string, default: "Normal"   # Normal ya NRI
    add_column :bookings, :address, :string
    add_column :bookings, :total_price, :decimal, precision: 10, scale: 2
    change_column :bookings, :status, :string, default: "pending"
  end
end