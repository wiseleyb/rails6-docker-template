module Types
  class MutationType < Types::BaseObject
    field :create_article, mutation: Mutations::CreateArticle
    field :update_article, mutation: Mutations::UpdateArticle
    field :delete_article, mutation: Mutations::DeleteArticle 
  end
end
