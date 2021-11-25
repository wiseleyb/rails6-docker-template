class ApplicationController < ActionController::Base
  # TODO: Security
  # more on this https://stackoverflow.com/questions/14734243/rails-csrf-protection-angular-js-protect-from-forgery-makes-me-to-log-out-on
  # Skip authenticity tokens for test purpose
  skip_before_action :verify_authenticity_token

  def access_denied(exception)
    redirect_to '/', alert: exception.message
  end
end
