class ProjectWorkflow < ActiveRecord::Base
  unloadable

  belongs_to :workflow, class_name: 'ProjectWorkflow'
  belongs_to :new_status, class_name: 'IssueStatus'

  validates_presence_of :new_status_id

  self.inheritance_column = nil

  attr_accessible :project_id,
                  :id,
                  :workflow_transition_id,
                  :tracker_id,
                  :old_status_id,
                  :new_status_id,
                  :role_id,
                  :assignee,
                  :author,
                  :type,
                  :field_name,
                  :rule

  # def self.replace_workflows(trackers, roles, transitions, context)
  #   trackers = Array.wrap trackers
  #   roles = Array.wrap roles

  #   transaction do
  #     records = ProjectWorkflow.where(project_id: context.id, tracker_id: trackers.map(&:id), role_id: roles.map(&:id)).to_a

  #     transitions.each do |old_status_id, transitions_by_new_status|
  #       transitions_by_new_status.each do |new_status_id, transition_by_rule|
  #         transition_by_rule.each do |rule, transition|
  #           trackers.each do |tracker|
  #             roles.each do |role|
  #               w = records.select {|r|
  #                 r.old_status_id == old_status_id.to_i &&
  #                 r.new_status_id == new_status_id.to_i &&
  #                 r.tracker_id == tracker.id &&
  #                 r.role_id == role.id &&
  #                 !r.destroyed?
  #               }

  #               if rule == 'always'
  #                 w = w.select {|r| !r.author && !r.assignee}
  #               else
  #                 w = w.select {|r| r.author || r.assignee}
  #               end
  #               if w.size > 1
  #                 w[1..-1].each(&:destroy)
  #               end
  #               w = w.first

  #               if transition == "1" || transition == true
  #                 unless w
  #                   w = ProjectWorkflow.new(:old_status_id => old_status_id, :new_status_id => new_status_id, :tracker_id => tracker.id, :role_id => role.id)
  #                   records << w
  #                 end
  #                 w.author = true if rule == "author"
  #                 w.assignee = true if rule == "assignee"
  #                 w.save if w.changed?
  #               elsif w
  #                 if rule == 'always'
  #                   w.destroy
  #                 elsif rule == 'author'
  #                   if w.assignee
  #                     w.author = false
  #                     w.save if w.changed?
  #                   else
  #                     w.destroy
  #                   end
  #                 elsif rule == 'assignee'
  #                   if w.author
  #                     w.assignee = false
  #                     w.save if w.changed?
  #                   else
  #                     w.destroy
  #                   end
  #                 end
  #               end
  #             end
  #           end
  #         end
  #       end
  #     end
  #   end
  # end
end
