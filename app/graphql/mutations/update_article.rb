# app/graphql/mutations/update_article.rb
# frozen_string_literal: true

module Mutations
  # Update attributes on a book
  class UpdateArticle < BaseUpdateMutation
    mutation_field

    # Require an ID to be provided
    argument :id, ID, required: true

    # Allow the following fields to be updated. Each is optional.
    argument :title, String, required: false
    argument :text, String, required: false
    argument :user_id, ID, required: false

    #
    # The lookup method can be overridden
    # Make sure the field you use for record lookup is defined
    # as a required argument in lieu of :id.
    #
    # def find_record(some_other_field:, **_args)
    #   pundit_scope.find_by(some_other_field: some_other_field)
    # end

    #
    # There is also a hook invoked after successful update
    #
    # def after_update(record)
    #   ... do something after update ...
    # end
  end
end
