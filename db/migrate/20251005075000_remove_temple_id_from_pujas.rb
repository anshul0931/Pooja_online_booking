class RemoveTempleIdFromPujas < ActiveRecord::Migration[7.2]
  def change
    if column_exists?(:pujas, :temple_id)
      remove_column :pujas, :temple_id, :bigint
    end
  end
end
