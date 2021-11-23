class ApplicationController < ActionController::Base
  def access_denied(exception)
    redirect_to '/', alert: exception.message
  end
end
