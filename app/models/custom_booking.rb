class CustomBooking < ApplicationRecord
  # 🔹 Validations
  validates :user_name, presence: { message: "can't be blank" }
  validates :phone, presence: { message: "can't be blank" }, format: { with: /\A[0-9]{10,15}\z/, message: "must be 10–15 digits" }
  validates :email, presence: { message: "can't be blank" }, format: { with: URI::MailTo::EMAIL_REGEXP, message: "is not valid" }
  validates :seva_description, presence: { message: "can't be blank" }
  validates :status, presence: true, inclusion: { in: ["pending", "contacted", "confirmed", "rejected"] }

  # 🔹 ActiveAdmin / Ransack Attributes whitelist
  def self.ransackable_attributes(auth_object = nil)
    %w[
      id user_name phone email gotra seva_description status preferred_date location created_at updated_at
    ]
  end

  def self.ransackable_associations(auth_object = nil)
    []
  end
end
