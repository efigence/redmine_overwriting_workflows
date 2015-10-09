module RedmineOverwritingWorkflows
  module Patches
    module IssuePatch
      def self.included(base)
        base.class_eval do
          unloadable

          def workflow_rule_by_attribute(user = nil)
            return @workflow_rule_by_attribute if @workflow_rule_by_attribute && user.nil?

            user_real = user || User.current
            roles = user_real.admin ? Role.all.to_a : user_real.roles_for_project(project)
            roles = roles.select(&:consider_workflow?)
            return {} if roles.empty?

            result = {}
            workflow_permissions = ProjectWorkflow.where(tracker_id: tracker_id,
                                                         old_status_id: status_id,
                                                         role_id: roles.map(&:id),
                                                         project_id: project_id,
                                                         kind: 'WorkflowPermission').to_a
            if workflow_permissions.empty?
              workflow_permissions = WorkflowPermission.where(tracker_id: tracker_id,
                                                              old_status_id: status_id,
                                                              role_id: roles.map(&:id)).to_a
            end
            if workflow_permissions.any?
              workflow_rules = workflow_permissions.inject({}) do |h, wp|
                h[wp.field_name] ||= []
                h[wp.field_name] << wp.rule
                h
              end
              workflow_rules.each do |attr, rules|
                next if rules.size < roles.size
                uniq_rules = rules.uniq
                if uniq_rules.size == 1
                  result[attr] = uniq_rules.first
                else
                  result[attr] = 'required'
                end
              end
            end
            @workflow_rule_by_attribute = result if user.nil?
            result
          end

          def new_statuses_allowed_to(user = User.current, include_default = false)
            if new_record? && @copied_from
              [default_status, @copied_from.status].compact.uniq.sort
            else
              initial_status = nil
              if new_record?
                initial_status = default_status
              elsif tracker_id_changed?
                if Tracker.where(id: tracker_id_was, default_status_id: status_id_was).any?
                  initial_status = default_status
                elsif tracker.issue_status_ids.include?(status_id_was)
                  initial_status = IssueStatus.find_by_id(status_id_was)
                else
                  initial_status = default_status
                end
              else
                initial_status = status_was
              end

              initial_assigned_to_id = assigned_to_id_changed? ? assigned_to_id_was : assigned_to_id
              assignee_transitions_allowed = initial_assigned_to_id.present? &&
                                             (user.id == initial_assigned_to_id || user.group_ids.include?(initial_assigned_to_id))

              statuses = []
              if initial_status
                statuses += initial_status.find_new_statuses_allowed_to(
                  user.admin ? Role.all.to_a : user.roles_for_project(project),
                  tracker,
                  author == user,
                  assignee_transitions_allowed,
                  project
                )
              end
              statuses << initial_status unless statuses.empty?
              statuses << default_status if include_default
              statuses = statuses.compact.uniq.sort
              statuses.reject!(&:is_closed?) if blocked?
              statuses
            end
          end
        end
      end
    end
  end
end

unless Issue.included_modules.include?(RedmineOverwritingWorkflows::Patches::IssuePatch)
  Issue.send(:include, RedmineOverwritingWorkflows::Patches::IssuePatch)
end
