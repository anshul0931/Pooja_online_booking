class AddGotraToBookings < ActiveRecord::Migration[7.2]
  def change
    add_column :bookings, :gotra, :string
  end
end
