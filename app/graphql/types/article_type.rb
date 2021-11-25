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
    implements Types::RecordType

    #belongs_to :user

    field :title, String, null: true
    field :text, String, null: true
    field :user, UserType, null: false, description: 'The author'

    # Defined i RecordType
    #field :id, ID, null: false
    #field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    #field :updated_at, GraphQL::Types::ISO8601DateTime, null: false
  end
end
