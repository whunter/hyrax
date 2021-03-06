module Sipity
  # A named workflow for processing an entity. Originally I had thought of
  # calling this a Type, but once I extracted the Processing submodule,
  # type felt to much of a noun, not conveying potentiality. Workflow
  # conveys "things will happen" because of this.
  class Workflow < ActiveRecord::Base
    self.table_name = 'sipity_workflows'

    has_many :entities, dependent: :destroy, class_name: 'Sipity::Entity'
    has_many :workflow_states, dependent: :destroy, class_name: 'Sipity::WorkflowState'
    has_many :workflow_actions, dependent: :destroy, class_name: 'Sipity::WorkflowAction'
    has_many :workflow_roles, dependent: :destroy, class_name: 'Sipity::WorkflowRole'

    # Each PermissionTemplate has multiple potential workflows. But only one "active" workflow
    # @see Sipity::Workflow.activate!
    belongs_to :permission_template, class_name: 'Hyrax::PermissionTemplate', required: true

    DEFAULT_INITIAL_WORKFLOW_STATE = 'new'.freeze
    def initial_workflow_state
      workflow_states.find_or_create_by!(name: DEFAULT_INITIAL_WORKFLOW_STATE)
    end

    # @api public
    # @param admin_set_id [#to_s] the admin set to which we will scope our query.
    # @return [Sipity::Workflow] that is active for the given administrative set`
    # @raise [ActiveRecord::RecordNotFound] when we don't have an active admin set for the given administrative set's ID
    def self.find_active_workflow_for(admin_set_id:)
      templates = Hyrax::PermissionTemplate.arel_table
      workflows = Sipity::Workflow.arel_table
      Sipity::Workflow.where(active: true).where(
        workflows[:permission_template_id].in(
          templates.project(templates[:id]).where(templates[:admin_set_id].eq(admin_set_id))
        )
      ).first!
    end

    # @api public
    #
    # Within the given permission_template scope:
    #   * Deactivate the current active workflow (if one exists)
    #   * Activate the specified workflow_id
    #
    # @param permission_template [Hyrax::PermissionTemplate] The scope for activation of the workflow id
    # @param workflow_id [Integer] The workflow_id within the given permission_template that should be activated
    # @param workflow_name [String] The name of the workflow within the given permission template that should be activated
    # @return [TrueClass]
    # @raise [ActiveRecord::RecordNotFound] When we have a mismatch on permission template and workflow id
    # @raise [RuntimeError] When you don't specify a workflow_id or workflow_name
    def self.activate!(permission_template:, workflow_id: nil, workflow_name: nil)
      raise "You must specify a workflow_id or workflow_name to activate!" if workflow_id.blank? && workflow_name.blank?
      finder_attributes = { permission_template: permission_template, id: workflow_id, name: workflow_name }.compact
      Sipity::Workflow.find_by!(finder_attributes).tap do |workflow|
        Sipity::Workflow.where(permission_template: permission_template, active: true).update(active: nil)
        workflow.update!(active: true)
      end
    end

    # Grant a workflow responsibility to a set of agents and remove it from any
    # agents who currently have the workflow responsibility, but are not in the
    # provided list
    # @param [Sipity::Role] role the role to grant
    # @param [Array<Sipity::Agent>] agents the agents to grant it to
    def update_responsibilities(role:, agents:)
      add_workflow_responsibilities(role, agents)
      remove_workflow_responsibilities(role, agents)
    end

    private

      # Give workflow responsibilites to the provided agents for the given role
      # @param [Sipity::Role] role
      # @param [Array<Sipity::Agent>] agents
      def add_workflow_responsibilities(role, agents)
        Hyrax::Workflow::PermissionGenerator.call(roles: role,
                                                  workflow: self,
                                                  agents: agents)
      end

      # Find any workflow_responsibilities held by agents not in the allowed_agents
      # and remove them
      # @param [Sipity::Role] role
      # @param [Array<Sipity::Agent>] allowed_agents
      def remove_workflow_responsibilities(role, allowed_agents)
        wf_role = Sipity::WorkflowRole.find_by(workflow: self, role_id: role)
        wf_role.workflow_responsibilities.where.not(agent: allowed_agents).destroy_all
      end
  end
end
