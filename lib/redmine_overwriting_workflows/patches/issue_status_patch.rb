module RedmineOverwritingWorkflows
  module Patches
    module IssueStatusPatch
      def self.included(base)
        base.class_eval do
          unloadable

          has_many :project_workflows, foreign_key: 'new_status_id'

          def new_statuses_allowed_to(roles, tracker, author = false, assignee = false, context = nil)
            if roles && tracker
              role_ids = roles.collect(&:id)
              if !context.nil? && context.is_a?(Project) && !find_project_workflows(roles, tracker, context).empty?
                workflows = find_project_workflows(roles, tracker, context)
              else
                workflows = self.workflows
              end
              transitions = workflows.select do |w|
                role_ids.include?(w.role_id) &&
                w.tracker_id == tracker.id &&
                ((!w.author && !w.assignee) || (author && w.author) || (assignee && w.assignee))
              end
              transitions.map(&:new_status).compact.sort
            else
              []
            end
          end

          def find_new_statuses_allowed_to(roles, tracker, author = false, assignee = false, context = nil)
            if roles.present? && tracker
              if !context.nil? && context.is_a?(Project) && !find_project_workflows(roles, tracker, context).empty?
                scope = IssueStatus
                        .joins(:project_workflows)
                        .where(project_workflows: { old_status_id: id, role_id: roles.map(&:id), tracker_id: tracker.id, project_id: context.id })
              else
                scope = IssueStatus
                        .joins(:workflow_transitions_as_new_status)
                        .where(workflows: { old_status_id: id, role_id: roles.map(&:id), tracker_id: tracker.id })
              end

              unless author && assignee
                if author || assignee
                  scope = scope.where('author = ? OR assignee = ?', author, assignee)
                else
                  scope = scope.where('author = ? AND assignee = ?', false, false)
                end
              end

              scope.uniq.to_a.sort
            else
              []
            end
          end

          private
          def find_project_workflows(roles, tracker, project)
            ProjectWorkflow.where(project_id: project.id, tracker_id: tracker.id, role_id: roles.map(&:id))
          end
        end
      end
    end
  end
end

unless IssueStatus.included_modules.include?(RedmineOverwritingWorkflows::Patches::IssueStatusPatch)
  IssueStatus.send(:include, RedmineOverwritingWorkflows::Patches::IssueStatusPatch)
end
