class Booking < ApplicationRecord
  belongs_to :puja  # now directly related to Puja

  def self.ransackable_attributes(auth_object = nil)
    %w[id user_name phone email samagri_required status notes location booking_date customer_type address total_price puja_id created_at updated_at]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[puja]
  end
end
