# app/graphql/mutations/delete_article.rb
# frozen_string_literal: true

module Mutations
  # Delete a book
  class DeleteArticle < BaseDeleteMutation
    mutation_field

    # You can specify a different destroy method
    # Default is: :destroy
    # use_destroy_method :burn_to_ashes

    # Require an ID to be provided
    argument :id, ID, required: true

    #
    # The lookup method can be overridden
    # Make sure the field you use for record lookup is defined
    # as a required argument in lieu of :id.
    #
    # def find_record(some_other_field:, **_args)
    #   pundit_scope.find_by(some_other_field: some_other_field)
    # end

    #
    # There is also a hook invoked after successful destroy
    #
    # def after_delete(record)
    #   ... do something after destroy ...
    # end
  end
end
