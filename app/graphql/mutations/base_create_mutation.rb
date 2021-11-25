# app/graphql/mutations/base_create_mutation.rb
# frozen_string_literal: true

module Mutations
  # A generic Mutation used to handle record creation. Creation mutations
  # can inherit this class.
  class BaseCreateMutation < BaseMutation
    null true

    #---------------------------------------
    # Class Methods
    #---------------------------------------
    # Setter used on classes to define the return field and optionally its type
    def self.mutation_field(field_name = nil, type_name: nil)
      @record_field_name = field_name&.to_sym
      @entity_type_name = type_name
      field(record_field_name, entity_type, null: true)
    end

    # Name of the field used in return values
    def self.record_field_name
      @record_field_name ||= entity_klass_name.to_s.underscore.to_sym
    end

    # Return the entity class name
    def self.entity_klass_name
      @entity_klass_name ||= to_s.demodulize.gsub('Create', '')
    end

    # Return the entity type used in the return value
    def self.entity_type_name
      @entity_type_name ||= entity_klass_name
    end

    # Return the GraphQL class type
    def self.entity_type
      @entity_type ||= "Types::#{entity_type_name}Type".constantize
    end

    # Return the underlying active record model class
    # Can be overridden in the child mutation if the entity name is
    # different from the model name.
    def self.model_klass
      @model_klass ||= entity_klass_name.constantize
    end

    #---------------------------------------
    # Instance Methods
    #---------------------------------------
    # Retrieve the current user from the GraphQL context.
    # This current user must be injected in context inside the GraphqlController.
    def current_user
      @current_user ||= context[:current_user]
    end

    # Check user authorization through Pundit (if defined)
    def authorized?(**args)
      super &&
        (
          !defined?(Pundit) ||
          (
            Pundit.policy(current_user, self.class.model_klass.new(create_args(args))).create? ||
            raise(Pundit::NotAuthorizedError)
          )
        )
    end

    # After create hook. Called upon successful save of the record.
    #
    # @param record [Any] A mutation record.
    #
    def after_create(_record)
      true
    end

    #
    # The attributes to use to create the model. May be overridden
    # by child classes to pass a reference to the current user (for example).
    #
    # @param [Hash<String,Any>] **args The arguments.
    #
    # @return [Hash<String,Any>] The model create arguments.
    #
    def create_args(**args)
      args
    end

    # Create the new record
    def resolve(**args)
      record = self.class.model_klass.new(create_args(**args))

      if record.save
        # Invoke overridable hook
        after_create(record)

        # Mutation status
        { success: true, self.class.record_field_name => record, errors: [] }
      else
        { success: false, self.class.record_field_name => nil, errors: format_errors(record) }
      end
    rescue ActiveRecord::RecordNotUnique
      # Handle specific case where attribute uniqueness is handled at database level instead
      # of being handled in the model. This is often the case when you need to leverage
      # create_or_find.
      record_not_unique_error
    end

    # Format ActiveRecord errors into a [Types::MutationErrorType] array
    # Specific implimentation for unique key violations
    def record_not_unique_error
      {
        success: false,
        errors: [
          {
            code: 'record-not-unique',
            path: [self.class.name.demodulize.camelize(:lower)],
            message: 'record not unique'
          }
        ],
        self.class.record_field_name => nil
      }
    end
  end
end
