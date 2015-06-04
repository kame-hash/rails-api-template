# user.rb
class User < ApplicationRecord
  include Devise::JWT::RevocationStrategies::JTIMatcher
  # Use devise for authentication
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :jwt_authenticatable, jwt_revocation_strategy: self

  has_many :posts, dependent: :destroy
  has_many :comments, dependent: :destroy

  # Use pundit for authorization
  include Pundit

  # Validate user input
  validates :name, presence: true, length: { maximum: 50 }
  validates :email, presence: true, length: { maximum: 255 },
                    format: { with: /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i },
                    uniqueness: { case_sensitive: false }

  # Before saving user to database, convert email to lowercase
  before_save { email.downcase! }

  # Use sidekiq for background jobs
  include Sidekiq::Worker

  # Perform background job to send welcome email to user
  def send_welcome_email
    UserMailer.with(user: self).welcome_email.deliver_later
  end

  # Custom method to get user details
  def get_user_details
    {
      id: id,
      name: name,
      email: email,
      posts: posts.count,
      comments: comments.count
    }
  end

  # Rescue from ActiveRecord errors
  rescue_from ActiveRecord::RecordInvalid, with: :render_error
  rescue_from Pundit::NotAuthorizedError, with: :render_pundit_error

  private

  # Render error response
  def render_error(exception)
    render json: { error: exception.message }, status: :unprocessable_entity
  end

  # Render pundit error response
  def render_pundit_error(exception)
    render json: { error: exception.message }, status: :forbidden
  end
end