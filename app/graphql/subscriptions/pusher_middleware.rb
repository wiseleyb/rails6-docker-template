# app/graphql/subscriptions/pusher_middleware.rb

module Subscriptions
  #
  # Handle GraphQL subscriptions. Subscriptions are stored in redis and delivered via Pusher
  #
  # For each event subscription, three redis entries are used:
  #
  # > The sub_content_key key:
  #   - the key is based on the user ID and the event the user subscribes to
  #   - it stores the details (including context) of the user requested subscription
  #   - it is used to retrieve the context (e.g. current user) of the subscription
  #
  # > The event_to_users_key:
  #   - the key is based on the event the user subscribes to (it ignores user-specific details)
  #   - it is a redis `Set` which contains the list of users having subscribed
  #   - it is used to lookup the list of users which must be notified when an event is triggered
  #
  # > The user_to_events_key key:
  #   - the key is based on the user ID (it ignores event-specific details)
  #   - it is a redis `Set` which contains the list of events a specific user has subscribed to
  #   - it used to authorize access to Pusher channels as well as unsubscribe users from all their subscriptions
  #
  class PusherMiddleware < GraphQL::Subscriptions
    # Redis connection pool config
    # You may want to load the redis URL from a configuration file
    REDIS_URL = ENV.fetch('REDIS_URL', 'redis://redis:6379/1')
    REDIS_POOL_SIZE = ENV.fetch('RAILS_MAX_THREADS') { 25 }
    REDIS_POOL_TIMEOUT = 5 # seconds

    # The redis namespace under which the list of events each user has subscribed
    # to is stored.
    USER_EVENTS_NS = 'graphql/sub/user'

    # The redis namespace under which the list of users each event is subscribed
    # to is stored.
    EVENT_USERS_NS = 'graphql/sub/event'

    # The redis namespace under which subscription details are stored
    SUB_CONTENT_NS = 'graphql/sub/content'

    # The type of event to send to Pusher when records are modified
    PUSHER_EVENT_TYPE = 'update'

    # Websocket channel prefix. The 'private-' means this is a private channel and users
    # must be authenticated to subscribe to them.
    # See: https://pusher.com/docs/channels/using_channels/channels
    WS_CHANNEL_PREFIX = 'private'

    #
    # Return a connection pool to redis.
    #
    # @return [ConnectionPool] Redis connection pool.
    #
    def self.redis
      @redis ||= ConnectionPool.new(size: REDIS_POOL_SIZE, timeout: REDIS_POOL_TIMEOUT) do
        Redis.new(url: REDIS_URL)
      end
    end

    #
    # Alias to the Redis connection pool.
    #
    # @return [ConnectionPool] The redis connection pool.
    #
    def redis
      self.class.redis
    end

    #
    # Extract the requesting User ID from the query context. Used to associate the
    # subscription to the requesting user.
    #
    # @param query [GraphQL::Query]
    #
    # @return String the user ID
    #
    def user_id(query)
      query.context[:current_user].id
    end

    #
    # The redis key used to store all event IDs a user has subscribed to.
    #
    # @param [String] id The user unique reference.
    #
    # @return [String] The redis key.
    #
    def user_to_events_key(id)
      "#{USER_EVENTS_NS}/#{id}"
    end

    #
    # The redis key used to store all user IDs subscribed to an event.
    #
    # @param [String] id The event id/topic.
    #
    # @return [String] The redis key.
    #
    def event_to_users_key(id)
      "#{EVENT_USERS_NS}/#{id}"
    end

    #
    # The redis key to use for storing subscription content.
    #
    # @param [String] subscription_id The subscription ID.
    #
    # @return [String] The redis key.
    #
    def sub_content_key(subscription_id)
      "#{SUB_CONTENT_NS}:#{subscription_id}"
    end

    #
    # Build subscription ID from event and user_id.
    #
    # The subscription ID is based on the user_id it is sent to and event topic.
    # This means that only one subscription will be created per user_id and per subscription query.
    #
    # @param [GraphQL::Subscriptions::Event] event The event related to this subscription.
    # @param [String] user_id The name of the user_id this subscription belongs to.
    #
    # @return [String] A unique Pusher channel name.
    #
    def build_id(event, user_id)
      "#{WS_CHANNEL_PREFIX}-#{Digest::SHA256.hexdigest("#{event.topic}:#{user_id}")}"
    end

    #
    # Subscription `query` was executed with subscriptions to `events`.
    # Add/update subscription in redis and open new Pusher channel.
    #
    # @param query [GraphQL::Query]
    #
    # @param events [Array<GraphQL::Subscriptions::Event>]
    #
    # @return [void]
    #
    def write_subscription(query, events)
      # Extract subscribing user ID
      sub_user_id = user_id(query)

      # Serialize the subscription query
      sub_content = {
        query_string: query.query_string,
        variables: query.provided_variables,
        context: query.context,
        operation_name: query.operation_name
      }

      # Register a subscription for each event
      events.each do |event|
        sub_id = sub_content[:context][:subscription_id] = build_id(event, sub_user_id)
        sub_content[:context][:event_topic] = event.topic

        redis.with do |conn|
          conn.set(sub_content_key(sub_id), sub_content.to_json)
          conn.sadd(event_to_users_key(event.topic), sub_id)
          conn.sadd(user_to_events_key(sub_user_id), sub_id)
        end
      end
    end

    #
    # Get each `subscription_id` subscribed to `event.topic` and yield them
    #
    # @param event [GraphQL::Subscriptions::Event]
    #
    # @yieldparam subscription_id [String]
    #
    # @return [void]
    #
    def each_subscription_id(event)
      redis.with do |conn|
        conn.smembers(event_to_users_key(event.topic)).each do |sub_id|
          yield(sub_id)
        # rescue Pundit::NotAuthorizedError
        #   Rails.logger.info("Subscription id=#{sub_id} NOT delivered as current_api_user does not have READ access to the record.")
        #   nil
        end
      end
    end

    #
    # The system wants to send an update to this subscription.
    # Read its data, deserialize the ApiUser and return the content.
    #
    # @param subscription_id [String]
    #
    # @return [Hash] Containing required keys
    #
    def read_subscription(subscription_id)
      content = JSON.parse(redis.with { |c| c.get(sub_content_key(subscription_id)) }).deep_symbolize_keys
      user_attrs = content[:context][:current_user]
      content[:context][:current_user] = User.new(user_attrs)
      content
    end

    #
    # A subscription query was re-evaluated, returning `result`.
    # The result should be send to `subscription_id`.
    #
    # @param subscription_id [String]
    #
    # @param result [Hash]
    #
    # @return [void]
    #
    def deliver(subscription_id, result)
      # Send update via Pusher
      rs = ::Pusher.trigger(subscription_id, PUSHER_EVENT_TYPE, result.to_h)
      Rails.logger.debug {
        "GraphQL subscription delivered subscription=#{subscription_id} "\
          "result=#{result.to_h}"
      }
      rs
    rescue ::Pusher::Error => e
      Rails.logger.error(e)
      nil
    end

    #
    # A subscription was terminated server-side.
    # Clean up the database.
    #
    # @param subscription_id [String]
    #
    # @return void.
    #
    def delete_subscription(subscription_id)
      event_topic = read_subscription(subscription_id)[:context][:event_topic]

      redis.with do |conn|
        conn.srem(event_to_users_key(event_topic), subscription_id)
        conn.del(sub_content_key(subscription_id))
      end
    end

    #
    # A subscription was terminated server-side.
    # Clean up the database.
    #
    # @param subscription_id [String]
    #
    # @return void.
    #
    def delete_user_subscriptions(user_id)
      redis.with do |conn|
        conn.smembers(user_to_events_key(user_id)).each do |sub_id|
          delete_subscription(sub_id)
        end
        conn.del(user_to_events_key(user_id))
      end
    end

    #
    # Return true if the subscription_id belongs to the channel.
    #
    # @param [String] user_id A user user_id.
    # @param [String] subscription_id A subscription_id
    #
    # @return [Boolean] True if the subscription belongs to the channel.
    #
    def user_subscription?(user_id, subscription_id)
      redis.with { |c| c.sismember(user_to_events_key(user_id), subscription_id) }
    end

    #
    # Return the number of subscribers to a specific event
    #
    # @param [String] event_name The event name.
    # @param [Hash<String, Symbol => Object] args The event arguments.
    # @param [Symbol, String] scope The scope of the event
    #
    # @return [Integer] The number of subscribers for the event.
    #
    def subscribers_count(event_name, args, scope: nil)
      topic = event_for(event_name, args, scope: scope)&.topic
      return 0 unless topic.present?

      # Retrieve the number of subscribers
      redis.with { |c| c.scard(event_to_users_key(topic)) }
    end
  end
end
