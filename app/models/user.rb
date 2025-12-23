class User < ApplicationRecord
  has_many :entities_users, dependent: :destroy
  has_many :entities, through: :entities_users

  validates :first_name, :last_name, :email, :phone, presence: true
  validates :email, uniqueness: true

  after_create_commit :send_welcome_email

  private

  def send_welcome_email
    call_to_action = { label: "Acesse agora", url: "https://fintera.com.br" }
    UserMailer.welcome_email(self, call_to_action).deliver_later
  end
end