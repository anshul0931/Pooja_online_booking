class CreateConversationMessages < ActiveRecord::Migration[7.2]
  def change
    create_table :conversation_messages do |t|
      t.string :phone_number, null: false
      t.string :role, null: false
      t.text :content, null: false

      t.timestamps
    end

    add_index :conversation_messages, :phone_number
  end
end
