class Temple < ApplicationRecord
  has_many :pujas, dependent: :destroy
end
