class Subscription < ApplicationRecord
  validates :email, presence: true
  validates :origin, presence: true
  validates :destination, presence: true
  validates :date_start, presence: true
  validates :date_end, presence: true
end
