module RedmineOverwritingWorkflows
  module Patches
    module WorkflowTransitionPatch
      def self.included(base)
        base.class_eval do
          unloadable

          has_many :project_workflows

        end
      end
    end
  end
end

unless WorkflowTransition.included_modules.include?(RedmineOverwritingWorkflows::Patches::WorkflowTransitionPatch)
  WorkflowTransition.send(:include, RedmineOverwritingWorkflows::Patches::WorkflowTransitionPatch)
end
