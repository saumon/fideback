class Subject < ApplicationRecord
  belongs_to :campaign
  belongs_to :contact, optional: true
  has_many :answers, dependent: :destroy

  normalizes :email, with: ->(email) { email.strip.downcase }

  validates :name, :email, presence: true
  validates :email, uniqueness: { scope: :campaign_id, case_sensitive: false },
                    format: { with: URI::MailTo::EMAIL_REGEXP, allow_blank: true }
end
