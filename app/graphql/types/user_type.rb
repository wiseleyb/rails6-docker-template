module Types
  class UserType < Types::BaseObject
    implements Types::RecordType

    has_many :articles

    field :name, String, null: true
    field :email, String, null: false
    field :encrypted_password, String, null: false
    field :reset_password_token, String, null: true
    field :reset_password_sent_at, GraphQL::Types::ISO8601DateTime, null: true
    field :remember_created_at, GraphQL::Types::ISO8601DateTime, null: true

    # defined in RecordType 
    #field :id, ID, null: false
    #field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    #field :updated_at, GraphQL::Types::ISO8601DateTime, null: false
  end
end
