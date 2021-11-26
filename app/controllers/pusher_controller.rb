# app/controllers/pusher_controller.rb

# This controller handles interactions with Pusher:
# - private channel authorization
# - Subscription webhooks.
class PusherController < ApplicationController
  #
  # POST /pusher/auth
  #
  # Used by Pusher to authenticate private channels
  #
  # See: https://pusher.com/docs/channels/server_api/authenticating-users#implementing-authentication-endpoints
  #
  def auth
    if user_channel?(current_user, params[:channel_name])
      response = Pusher.authenticate(params[:channel_name], params[:socket_id])
      render json: response
    else
      render text: 'Forbidden', status: '403'
    end
  end

  #
  # POST /pusher/webhooks
  #
  # Used by Pusher to send updates on webhooks subscriptions. Only used
  # to handle channel unsubscribe events for now.
  #
  # See: https://pusher.com/docs/channels/server_api/webhooks#channel-existence-events
  #
  def webhooks
    webhook = Pusher::WebHook.new(request)

    # Abort if webhook is invalid
    unless webhook.valid?
      render text: 'invalid', status: 401
      return
    end

    # Process Pusher events
    webhook.events.each do |event|
      if event['name'] == 'channel_vacated'
        RailsondockerSchema.subscriptions.delete_user_subscriptions(event['channel'])
      end
    end

    render text: 'ok'
  end

  #---------------------------------------
  # Private
  #---------------------------------------
  private

  #
  # Return true if the Pusher channel belongs to the user
  #
  # @param [ApiUser] user The user.
  # @param [String] channel_name The channel name
  #
  # @return [Boolean] True if the channel is valid
  #
  def user_channel?(user, channel_name)
    return false if user.blank?

    RailsondockerSchema.subscriptions.user_subscription?(user.id, channel_name)
  end
end
