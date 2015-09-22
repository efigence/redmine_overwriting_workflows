module RedmineOverwritingWorkflows
  module Patches
    module IssueStatusPatch
      def self.included(base)
        base.class_eval do
          unloadable

          def new_statuses_allowed_to_with_project(roles, tracker, author=false, assignee=false, context = nil)
            if context != nil && contect.is_a?(Project)
              workflows = ProjectWorkflows.where("project_id =?", context.id)
              return workflows if !workflows.empty?
            end
            new_statuses_allowed_to_without_project(roles, tracker, author=false, assignee=false)
          end

          alias_method_chain :new_statuses_allowed_to, :project

          # def find_new_statuses_allowed_to(roles, tracker, author=false, assignee=false)

       end
     end
   end
 end
end

unless IssueStatus.included_modules.include?(RedmineOverwritingWorkflows::Patches::IssueStatusPatch)
  IssueStatus.send(:include, RedmineOverwritingWorkflows::Patches::IssueStatusPatch)
end
