class Puja < ApplicationRecord
  has_one_attached :image
  has_many :bookings, dependent: :destroy

  def self.ransackable_attributes(auth_object = nil)
    %w[id title description duration_minutes base_price created_at updated_at]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[bookings image_attachment image_blob]
  end
end
