class User < ApplicationRecord
  VALID_EMAIL_REGEX = Settings.user.email_regex
  USERS_PARAMS = %i(name email password password_confirmation).freeze
  RESET_PASSWORD_USERS_PARAMS = %i(password password_confirmation).freeze

  validates :name, presence: true,
    length: {maximum: Settings.user.username_maximum}

  validates :email, presence: true,
    length: {maximum: Settings.user.email_maximum},
    format: {with: VALID_EMAIL_REGEX},
    uniqueness: true

  validates :password, presence: true,
    length: {minimum: Settings.user.password_minimum},
    allow_nil: true

  has_secure_password

  attr_accessor :remember_token, :activation_token, :reset_token

  before_create :create_activation_digest
  before_save :email_downcase

  class << self
    def digest string
      cost = if ActiveModel::SecurePassword.min_cost
               BCrypt::Engine::MIN_COST
             else
               BCrypt::Engine.cost
             end
      BCrypt::Password.create string, cost: cost
    end

    def new_token
      SecureRandom.urlsafe_base64
    end
  end

  def remember
    self.remember_token = User.new_token
    update remember_digest: User.digest(remember_token)
  end

  def authenticated? attribute, token
    digest = send "#{attribute}_digest"
    return false unless digest

    BCrypt::Password.new(digest).is_password? token
  end

  def forget
    update remember_digest: nil
  end

  def activate
    update activated: true, activated_at: Time.zone.now
  end

  def send_activation_email
    UserMailer.account_activation(self).deliver_now
  end

  def create_reset_digest
    self.reset_token = User.new_token
    update reset_digest: User.digest(reset_token), reset_sent_at: Time.zone.now
  end

  def send_password_reset_email
    UserMailer.password_reset(self).deliver_now
  end

  def password_reset_expired?
    reset_sent_at < Settings.time.expried.hours.ago
  end

  private

  def user_params
    params.require(:user).permit :password, :password_confirmation
  end

  def email_downcase
    self.email = email.downcase
  end

  def create_activation_digest
    self.activation_token = User.new_token
    self.activation_digest = User.digest activation_token
  end
end
