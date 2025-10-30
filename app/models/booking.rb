class Booking < ApplicationRecord
  belongs_to :puja  # directly related to Puja

  # 🔹 Validations
  validates :user_name, presence: { message: "can't be blank" }
  validates :phone, presence: { message: "can't be blank" }, format: { with: /\A[0-9]{10,15}\z/, message: "must be 10–15 digits" }
  validates :email, presence: { message: "can't be blank" }, format: { with: URI::MailTo::EMAIL_REGEXP, message: "is not valid" }
  validates :customer_type, inclusion: { in: ["Indian", "NRI"], message: "must be either Indian or NRI" }
  validates :booking_date, presence: { message: "can't be blank" }
  validates :location, presence: { message: "can't be blank" }
  validates :puja_id, presence: true

  def self.ransackable_attributes(auth_object = nil)
    %w[
      id user_name phone email samagri_required status notes location booking_date
      customer_type address total_price puja_id created_at updated_at
    ]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[puja]
  end
end
