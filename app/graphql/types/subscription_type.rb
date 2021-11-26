module Types
  # Define all available GraphQL subscriptions
  class SubscriptionType < BaseObject
    # Book subscriptions
    field :article_updated, subscription: Subscriptions::ArticleModified
    field :article_deleted, subscription: Subscriptions::ArticleModified
  end
end
