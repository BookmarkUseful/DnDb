class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  helper_method :mobile?

  def default_url_options
    if Rails.env.development?
      {:host => "http://localhost:3000"}
    else  
      {}
    end
  end

  protected

   def mobile?
      request.user_agent =~ /\b(Android|iPhone|iPad|Windows Phone|Opera Mobi|Kindle|BackBerry|PlayBook)\b/i
   end

end
