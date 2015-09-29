module RedmineOverwritingWorkflows
  module Patches
    module IssuePatch
      def self.included(base)
        base.class_eval do
          unloadable

          def new_statuses_allowed_to(user=User.current, include_default=false, context=nil)
            if new_record? && @copied_from
              [default_status, @copied_from.status].compact.uniq.sort
            else
              initial_status = nil
              if new_record?
                initial_status = default_status
              elsif tracker_id_changed?
                if Tracker.where(:id => tracker_id_was, :default_status_id => status_id_was).any?
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
                  context
                  )
              end
              statuses << initial_status unless statuses.empty?
              statuses << default_status if include_default
              statuses = statuses.compact.uniq.sort
              if blocked?
                statuses.reject!(&:is_closed?)
              end
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