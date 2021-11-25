class Article < ApplicationRecord
  belongs_to :user

  scope :graphql_scope, -> { eager_load(:user) }

  # GraphQL subscription callbacks
  after_update_commit :notify_graphql_of_update
  after_destroy_commit :notify_graphql_of_delete

  #
  # Return the full GraphQL event name.
  #
  # @param [String] action The action name (updated, deleted)
  #
  # @return [String] The full GraphQL event name (e.g. articleUpdated, articleDeleted)
  #
  def graphql_event_name(action)
    "#{self.class.to_s.camelize(:lower)}#{action.camelize}"
  end

  #
  # Enqueue a GraphQL notification job
  #
  def notify_graphql_of_update
    # The trigger parameters are the following:
    # - Event name: it must match one of the events defined in the app/graphql/types/subscription_type.rb file
    # - Event scope: it must match the arguments of the handler defined in app/graphql/subscriptions/book_modified.rb
    # - Payload: it must match the subscription response object so as to populate the event content with the fields initially requested.
    RailsondockerSchema.subscriptions.trigger(graphql_event_name('updated'),
                                              { id: id },
                                              { article: self })
  end

  #
  # Enqueue a GraphQL notification job
  #
  def notify_graphql_of_delete
    MyAppSchema.subscriptions.trigger(graphql_event_name('deleted'),
                                      { id: id },
                                      { article: self })
  end
end
