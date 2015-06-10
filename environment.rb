# config/environment.rb
require_relative 'application'
require_relative 'boot'

# Load environment variables from .env file
ENV.update YAML.load_file('config/environments Variables.yml')[ENV['RAILS_ENV']]

# Configure Rails application
module RailsApiTemplate
  class Application < Rails::Application
    config.load_defaults 7.0
    config.api_only = true
    config.active_job.queue_adapter = :sidekiq

    # Configure Devise and JWT auth
    config.middleware.use Rack::Cors do
      allow do
        origins '*'
        resource '*', headers: :any, methods: [:get, :post, :put, :delete, :options]
      end
    end

    # Configure Pundit authorization policies
    config.authorization_policies = {
      user: ‘Users::UserPolicy’,
      post: ‘Posts::PostPolicy’
    }

    # Configure Sidekiq background jobs
    config.sidekiq_options = {
      url: ENV['SIDEKIQ_REDIS_URL'],
      namespace: 'rails-api-template'
    }

    # Handle exceptions
    config.exceptions_app = routes
  end
end

# Load environment-specific configuration
require_relative "#{Rails.root}/config/environments/#{Rails.env}.rb"