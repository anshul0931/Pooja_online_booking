class RemoveTempleIdFromPujas < ActiveRecord::Migration[7.2]
  def change
    remove_column :pujas, :temple_id, :bigint
  end
end
