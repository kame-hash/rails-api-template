# auth_token_middleware.rb
class AuthTokenMiddleware
  def initialize(app)
    @app = app
  end

  def call(env)
    # Check if request includes Authorization header
    auth_header = env['HTTP_AUTHORIZATION']
    return @app.call(env) unless auth_header

    # Extract token from Authorization header
    token = auth_header.split(' ').last
    begin
      # Decode and verify JWT token
      payload = JwtEncoder.decode(token)
      user_id = payload['user_id']
      # Find user by id
      user = User.find_by(id: user_id)
      # Set current user in request environment
      env['warden'] = { user: user }
    rescue JWT::VerificationError
      # Handle invalid or expired token
      error_response = { error: 'Invalid or expired authentication token' }
      return [401, { 'Content-Type' => 'application/json' }, [error_response.to_json]]
    rescue ActiveRecord::RecordNotFound
      # Handle user not found
      error_response = { error: 'User not found' }
      return [401, { 'Content-Type' => 'application/json' }, [error_response.to_json]]
    end

    # Continue with request
    @app.call(env)
  end
end