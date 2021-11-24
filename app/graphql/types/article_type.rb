module Types
  # NOTE: when you call this from GQL you need to camelCase ... example
  # {
  #  articles {
  #    id
  #    title
  #    text
  #    createdAt
  #    updatedAt
  #  }
  # }
  class ArticleType < Types::BaseObject
    field :id, ID, null: false
    field :title, String, null: true
    field :text, String, null: true
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false
  end
end
