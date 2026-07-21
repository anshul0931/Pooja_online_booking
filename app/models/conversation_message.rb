class ConversationMessage < ApplicationRecord
  validates :identifier, :role, :content, presence: true
  validates :role, inclusion: { in: %w[user assistant] }
end
