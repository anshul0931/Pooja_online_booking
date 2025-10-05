class RenamePoojaTypeIdToPujaIdInBookings < ActiveRecord::Migration[7.2]
  def change
    rename_column :bookings, :pooja_type_id, :puja_id
  end
end
