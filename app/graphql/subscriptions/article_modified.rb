# app/graphql/subscriptions/article_modified.rb

module Subscriptions
  # Handle authorization when events are subscribed to and triggered
  class ArticleModified < GraphQL::Schema::Subscription
    # The argument(s) that must be provided to subscribe
    argument :id, ID, required: true

    # The fields (content) that can be subscribed to
    field :artile, Types::ArticleType, null: false

    #
    # This method is called when:
    # - a user initially subscribes
    # - when an event is triggered internally.
    #
    def authorized?(id:)
      article = Article.find_by(id: id)

      (
        super &&
        article &&
        article.user_id == context[:current_user]&.id
        # => I strongly recommend using a proper framework like Pundit for authorization <=
        # && Pundit.policy!(context[:current_user], book).subscribe?
      )
      # ||
      # raise(Pundit::NotAuthorizedError)
    end
  end
end
