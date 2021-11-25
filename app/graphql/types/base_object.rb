module Types
  class BaseObject < GraphQL::Schema::Object
    edge_type_class(Types::BaseEdge)
    connection_type_class(Types::BaseConnection)
    field_class Types::BaseField

    #--------------------------------------------
    # Helpers
    #--------------------------------------------
    # Automatically generate find and list queries for a given resource
    def self.resource(entity, **args)
      entity_type = "Types::#{entity.to_s.singularize.classify}Type".constantize
      Rails.logger.info ''
      Rails.logger.info '*' * 80
      Rails.logger.info entity_type
      Rails.logger.info args.to_yaml
      Rails.logger.info '*' * 80
      Rails.logger.info ''

      record_resolver = args.delete(:record_resolver) ||
                        Resolvers::RecordQuery.for(entity_type, **args)
      collection_resolver = args.delete(:collection_resolver) ||
                            Resolvers::CollectionQuery.for(entity_type, **args)

      # Generate root field for entity find
      field entity.to_s.singularize.to_sym, entity_type,
            null: true,
            resolver: record_resolver,
            description: "Find #{entity.to_s.singularize.camelize}."

      # Generate root field for entity list with filtering
      field entity.to_s.pluralize.to_sym, entity_type.connection_type,
            null: false,
            resolver: collection_resolver,
            description: "Query #{entity.to_s.pluralize.camelize} with filters."
    end

    # Define a has many relationship
    # E.g. inferred type
    # has_many :posts
    #
    # E.g. explicit type
    # has_many :published_posts, type: Type::PostType
    def self.has_many(rel_name, **args)
      inferred_type = rel_name.to_s.singularize.camelize
      model_klass_name = args.delete(:model_name) || inferred_type.classify
      entity_type = args[:type] || "Types::#{inferred_type}Type".constantize
      relation_name = args.delete(:relation) || rel_name
      resolver_klass = args.delete(:resolver_class) || Resolvers::CollectionQuery

      # Generate root field for entity list with filtering
      field rel_name, entity_type.connection_type,
            null: false,
            resolver: resolver_klass.for(entity_type, relation: relation_name, model_name: model_klass_name),
            description: "Query related #{rel_name.to_s.pluralize.camelize} with filters."
    end
  end
end
