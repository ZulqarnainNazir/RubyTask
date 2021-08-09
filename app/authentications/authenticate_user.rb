class AuthenticateUser
  prepend SimpleCommand

  def initialize(email, password)
    @email = email
    @password = password
  end

  def call
    encode(user_id: user.id) if user
  end

  private

  def encode(payload, exp = 24.hours.from_now)
    payload[:exp] = exp.to_i
    JWT.encode(payload, Rails.application.secrets.secret_key_base)
  end

  def user
    user = User.find_by!(email: @email)
    return user if user&.authenticate(@password)

    errors.add(:user_authentication, "Invalid Credentials")
    return nil
  end
end
