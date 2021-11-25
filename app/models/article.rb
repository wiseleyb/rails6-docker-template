class Article < ApplicationRecord
  belongs_to :user

  scope :graphql_scope, -> { eager_load(:user) }
end
