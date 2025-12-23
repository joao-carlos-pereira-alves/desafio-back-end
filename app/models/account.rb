class Account < ApplicationRecord
  has_many :entities, dependent: :destroy

  validates :name, presence: true
  validates :active, inclusion: { in: [true, false] }
end