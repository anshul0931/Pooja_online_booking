class RenamePhoneNumberToIdentifierInConversationMessages < ActiveRecord::Migration[7.2]
  def change
    rename_column :conversation_messages, :phone_number, :identifier
  end
end
