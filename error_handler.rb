# error_handler.rb
class ErrorHandler < StandardError
  def initialize(message, status)
    @message = message
    @status = status
    super(message)
  end

  def status
    @status
  end
end

class InvalidAuthToken < ErrorHandler
  def initialize
    super('Invalid authentication token', 401)
  end
end

class InvalidCredentials < ErrorHandler
  def initialize
    super('Invalid email or password', 401)
  end
end

class ActiveRecordError < ErrorHandler
  def initialize(message)
    super(message, 500)
  end
end

class ServiceError < ErrorHandler
  def initialize(message)
    super(message, 422)
  end
end

module ErrorHandling
  def handle_errors
    yield
  rescue ActiveRecord::RecordNotFound => e
    render json: { error: 'Record not found' }, status: 404
  rescue Pundit::NotAuthorizedError => e
    render json: { error: 'Not authorized' }, status: 403
  rescue ErrorHandler => e
    render json: { error: e.message }, status: e.status
  rescue StandardError => e
    render json: { error: 'Internal server error' }, status: 500
  end
end

module ActionController
  class API < ActionController::Metal
    include ErrorHandling

    def render_error(exception)
      # log the error
      Rails.logger.error exception
      # render error response
      render json: { error: exception.message }, status: exception.status
    end
  end
end 

def render_service_error(service, message)
  render json: { error: message }, status: 422
end 

def render_ activerecord_error(exception)
  render json: { error: exception.message }, status: 500
end 

rescue_in_transaction = true