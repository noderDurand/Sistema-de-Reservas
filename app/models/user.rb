class User < ApplicationRecord
  has_secure_password
  has_secure_token :api_token

  has_many :reservas, dependent: :destroy

  validates :name, presence: true
  validates :email, presence: true, uniqueness: true,
    format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :role, inclusion: { in: %w[cliente admin] }

  before_validation { self.role ||= "cliente" }
end
