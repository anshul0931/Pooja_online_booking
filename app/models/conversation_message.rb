class ConversationMessage < ApplicationRecord
  validates :phone_number, :role, :content, presence: true
  validates :role, inclusion: { in: %w[user assistant] }
end
