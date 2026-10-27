class Manager < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :campaigns, dependent: :destroy

  validates :name, presence: true
end
