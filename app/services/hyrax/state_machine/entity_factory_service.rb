module Hyrax
  module StateMachine
    module EntityFactoryService
      class CreateEntityError < RuntimeError
      end
      class EntityNotFoundError < RuntimeError
      end
      class NoRegistrationFoundError < RuntimeError
      end

      # @api public
      #
      # For the given :subject and :agent, find or create the corresponding Sipity::Entity.
      #
      # @param [Object, Symbol, String] subject - The thing that was created and for which we now need to assign a Sipity::Entity
      # @param [#agent_uri] agent - An Agent object (e.g. who created the given subject)
      # @return [Sipity::Entity]
      # @raise [Hyrax::StateMachine::EntityFactoryService::CreateEntityError]
      # @see Sipity::Entity
      # @see Hyrax::StateMachine::EntityFactoryService#create_entity_for
      # @see Hyrax::StateMachine::EntityFactoryService#find_entity_for
      def self.find_or_create_entity_for(subject:, agent:)
      end

      # @api public
      #
      # For the given :subject find the corresponding Sipity::Entity.
      #
      # @param [Object, Symbol, String] subject - The thing that was created and for which we now need to assign a Sipity::Entity
      # @return [Sipity::Entity]
      # @raise [Hyrax::StateMachine::EntityFactoryService::EntityNotFoundError]
      # @see Sipity::Entity
      # @see Hyrax::StateMachine::EntityFactoryService::EntityForRegistry
      def self.find_entity_for!(subject:)
      end

      # Responsible for orchestrating the sequence of Registrants::Base objects.
      #
      # @todo Expose a way to define the registrations and reorder them
      #
      # @see Hyrax::StateMachine::EntityFactoryService::Registrations::Base
      class Registry
        # Responsible for looping through the registry, and returning the first Registrations::Base object in which #valid? == true
        #
        # @param [Object, Symbol, String] subject - The thing that we are trying to convert to a Sipity::Entity
        # @return [Hyrax::StateMachine::EntityFactoryService::Registrations::Base]
        # @raise [Hyrax::StateMachine::EntityFactoryService::NoRegistrationFoundError] if we can't find a valid registration for the given subject
        def registration_for(subject:)git s
        end
      end

      # A namespace for defining the various registrants
      module Registrations
        # Responsible for exposing methods to:
        # * find the given subject's Sipity::Entity
        # * create the given subject & agent's Sipity::Entity
        class Base
          def initialize(subject:)
          end

          # For the initialized :subject, is this registration valid?
          def valid?
          end

          # Find the corresponding Sipity::Entity for the initialized :subject
          #
          # @return [Sipity::Entity]
          def find
          end

          # Create the correct Sipity::Entity for the initialized :subject (assigning the correct state machine, state, and any entity specific responsibilities)
          #
          # @return [Sipity::Entity]
          def create(agent:)
          end
        end
      end
    end
  end
end
