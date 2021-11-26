# app/graphql/types/mutation_error_type.rb
# frozen_string_literal: true

module Types
  class MutationErrorType < BaseObject
    description 'An error related to a record operation'

    field :code,
          String,
          null: false,
          description: 'A code for the error'
    field :message,
          String,
          null: false,
          description: 'A description of the error'
    field :path,
          [String],
          null: true,
          description: 'Which input value this error came from'
  end
end
