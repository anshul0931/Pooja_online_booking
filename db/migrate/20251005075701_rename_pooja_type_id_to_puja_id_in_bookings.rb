class RenamePoojaTypeIdToPujaIdInBookings < ActiveRecord::Migration[7.2]
  def change
    if column_exists?(:bookings, :pooja_type_id)
      rename_column :bookings, :pooja_type_id, :puja_id
    end
  end
end
