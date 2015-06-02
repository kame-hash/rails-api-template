# user_service.rb
class UserService
  def initialize(user)
    @user = user
  end

  def create_session
    # Generate a new JWT token for the user
    token = JsonWebToken.encode(user_id: @user.id)
    # Create a new session for the user
    Session.create(user_id: @user.id, token: token)
    token
  rescue StandardError => e
    # Log the error and return nil
    Rails.logger.error("Error creating session: #{e.message}")
    nil
  end

  def validate_session(token)
    # Decode the JWT token
    decoded_token = JsonWebToken.decode(token)
    # Check if the token is valid
    if decoded_token && decoded_token['user_id'] == @user.id
      # Return true if the token is valid
      true
    else
      # Return false if the token is invalid
      false
    rescue StandardError => e
      # Log the error and return false
      Rails.logger.error("Error validating session: #{e.message}")
      false
    end
  end

  def update_user_info(attributes)
    # Update the user's info
    if @user.update(attributes)
      # Return true if the update is successful
      true
    else
      # Return false if the update fails
      false
    end
  end

  def send_password_reset_email
    # Generate a new password reset token
    @user.generate_password_reset_token
    # Send a password reset email to the user
    UserMailer.password_reset(@user).deliver_later
  end

  private

  def user_id
    @user.id
  end
end