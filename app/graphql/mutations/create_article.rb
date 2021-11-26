# app/graphql/mutations/create_article.rb
# frozen_string_literal: true

module Mutations
  # Mutation used to create books
  class CreateArticle < BaseCreateMutation
    mutation_field

    argument :title,
             String,
             required: true,
             description: 'The title of the article.'
    argument :text,
              String,
              required: false,
              description: 'Article text.'
    argument :user_id,
             ID,
             required: true,
             description: 'The ID of the author.'
  end
end
