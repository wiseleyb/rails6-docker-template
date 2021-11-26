class ApplicationRecord < ActiveRecord::Base
  include GraphqlQueryScopes

  self.abstract_class = true
end
