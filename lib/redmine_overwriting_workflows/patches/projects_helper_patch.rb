require_dependency 'projects_helper'

module RedmineOverwritingWorkflows
  module Patches
    module ProjectsHelperPatch
      def self.included(base)
        base.class_eval do
          unloadable

          def project_settings_tabs_with_project_workflows
            tabs = project_settings_tabs_without_project_workflows

            if User.current.allowed_to?(:manage_workflows, @project) || User.current.admin?

              tabs << {
                name: 'workflows_transitions',
                action: :manage_project_workflow_transitions,
                partial: 'projects/settings/workflow_transitions',
                label: :project_workflow_transitions_settings
              }

              tabs << {
                name: 'workflows_permissions',
                action: :manage_project_workflow_permissions,
                partial: 'projects/settings/workflow_permissions',
                label: :project_workflow_permissions_settings
              }
            end
            tabs
          end

          alias_method_chain :project_settings_tabs, :project_workflows
        end
      end
    end
  end
end

unless ProjectsHelper.included_modules.include?(RedmineOverwritingWorkflows::Patches::ProjectsHelperPatch)
  ProjectsHelper.send(:include, RedmineOverwritingWorkflows::Patches::ProjectsHelperPatch)
end
