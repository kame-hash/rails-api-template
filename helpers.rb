# utils/helpers.rb
module Helpers
  def self.current_user(request)
    # Get the current user from the request's authorization header
    token = request.headers['Authorization']
    return nil unless token

    begin
      # Decode the JWT token and get the user's ID
      decoded_token = JsonWebToken.decode(token)
      User.find(decoded_token[:user_id])
    rescue ActiveRecord::RecordNotFound
      # If the user is not found, return nil
      nil
    rescue JWT::VerificationError
      # If the token is invalid, return nil
      nil
    end
  end

  def self.pundit_user(current_user)
    # Create a pundit user object
    Pundit::User.new(current_user)
  end

  def self.error_response(error)
    # Return an error response with a 500 status code
    { error: error.message, status: 500 }
  end

  def self.not_found_response
    # Return a not found response with a 404 status code
    { error: 'Not Found', status: 404 }
  end

  def self.serialize_user(user)
    # Serialize the user object to a JSON response
    {
      id: user.id,
      email: user.email,
      name: user.name
    }
  end

  def self.enqueue_job(job_class, *args)
    # Enqueue a Sidekiq job with the given arguments
    job_class.perform_async(*args)
  end

  def self.generate_token(user)
    # Generate a JWT token for the given user
    JsonWebToken.encode(user_id: user.id)
  end

  def self.validate_params(params, required_params)
    # Validate the given params to ensure all required params are present
    required_params.each do |param|
      return false unless params.key?(param)
    end
    true
  end
end