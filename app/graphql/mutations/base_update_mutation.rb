# app/graphql/mutations/base_update_mutation.rb
# frozen_string_literal: true

module Mutations
  # A generic Mutation used to handle record update
  class BaseUpdateMutation < BaseMutation
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
      @entity_klass_name ||= to_s.demodulize.gsub('Update', '')
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

    # Return the model Pundit Policy class
    def self.pundit_scope_klass
      @pundit_scope_klass ||= "#{model_klass}Policy::Scope".constantize
    end

    #---------------------------------------
    # Instance Methods
    #---------------------------------------
    # Retrieve the current user from the GraphQL context.
    # This current user must be injected in context inside the GraphqlController.
    def current_user
      @current_user ||= context[:current_user]
    end

    # Return the instantiated resource scope via Pundit
    def pundit_scope
      if defined?(Pundit)
        self.class.pundit_scope_klass.new(current_user, self.class.model_klass).resolve
      else
        self.class.model_klass
      end
    end

    # The method used to lookup the record
    def find_record(id:, **_args)
      pundit_scope.find_by(id: id)
    end

    #
    # Check user authorization through Pundit.
    #
    # Policy check:
    # - The original record goes through policies as it is fetched via Pundit scope
    # - The *modified* record goes through policies via the `action?` rule
    #
    # Null record:
    # If the record is not found, the action is allowed to proceed so as to let the
    # resolve method format the API errors.
    #
    #
    def authorized?(**args)
      # Retrieve record via user-specific scope
      record = find_record(**args)
      return super if record.nil?

      # Get modified version of the record before action policy is checked
      record.assign_attributes(args)

      # Check policy
      super &&
        (
          !defined?(Pundit) ||
          (
            Pundit.policy(current_user, record).update? ||
            raise(Pundit::NotAuthorizedError)
          )
        )
    end

    #
    # After update hook. Called upon successful save of the record.
    #
    # @param record [Any] A mutation record.
    #
    def after_update(_record)
      true
    end

    # Update the new record
    def resolve(**args)
      ActiveRecord::Base.transaction do
        # Get locked record
        record = find_record(**args)&.lock!

        # Update
        if record&.update(args)
          # Invoke post-update hook
          after_update(record)

          # Return result
          { success: true, self.class.record_field_name => record, errors: [] }
        else
          { success: false, self.class.record_field_name => nil, errors: format_errors(record) }
        end
      end
    end
  end
end
