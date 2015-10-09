class ProjectWorkflow < ActiveRecord::Base
  unloadable

  belongs_to :new_status, class_name: 'IssueStatus'

  validates_presence_of :new_status_id

  attr_accessible :project_id,
                  :id,
                  :tracker_id,
                  :old_status_id,
                  :new_status_id,
                  :role_id,
                  :assignee,
                  :author,
                  :kind,
                  :field_name,
                  :rule

  def self.rules_by_status_id(trackers, roles)
    ProjectWorkflow.where(tracker_id: trackers.map(&:id),
                          role_id: roles.map(&:id),
                          kind: 'WorkflowPermission').inject({}) do |h, w|
      h[w.old_status_id] ||= {}
      h[w.old_status_id][w.field_name] ||= []
      h[w.old_status_id][w.field_name] << w.rule
      h
    end
  end

  def self.replace_workflow_permissions(trackers, roles, permissions, context)
    trackers = Array.wrap trackers
    roles = Array.wrap roles

    transaction do
      permissions.each do |status_id, rule_by_field|
        rule_by_field.each do |field, rule|
          destroy_all(tracker_id: trackers.map(&:id),
                      role_id: roles.map(&:id),
                      old_status_id: status_id,
                      field_name: field,
                      kind: 'WorkflowPermission')
          if rule.present?
            trackers.each do |tracker|
              roles.each do |role|
                ProjectWorkflow.create(role_id: role.id,
                                       project_id: context.id,
                                       tracker_id: tracker.id,
                                       old_status_id: status_id,
                                       field_name: field,
                                       rule: rule,
                                       kind: 'WorkflowPermission')
              end
            end
          end
        end
      end
    end
  end

  def self.replace_workflows(trackers, roles, transitions, context)
    trackers = Array.wrap trackers
    roles = Array.wrap roles

    transaction do
      records = ProjectWorkflow.where(project_id: context.id,
                                      tracker_id: trackers.map(&:id),
                                      role_id: roles.map(&:id),
                                      kind: 'WorkflowTransition').to_a

      transitions.each do |old_status_id, transitions_by_new_status|
        transitions_by_new_status.each do |new_status_id, transition_by_rule|
          transition_by_rule.each do |rule, transition|
            trackers.each do |tracker|
              roles.each do |role|
                w = records.select do|r|
                  r.project_id == context.id &&
                  r.old_status_id == old_status_id.to_i &&
                  r.new_status_id == new_status_id.to_i &&
                  r.tracker_id == tracker.id &&
                  r.role_id == role.id &&
                  r.kind == 'WorkflowTransition' &&
                  !r.destroyed?
                end

                if rule == 'always'
                  w = w.select { |r| !r.author && !r.assignee }
                else
                  w = w.select { |r| r.author || r.assignee }
                end
                w[1..-1].each(&:destroy) if w.size > 1
                w = w.first

                if transition == '1' || transition == true
                  unless w
                    w = ProjectWorkflow.new(project_id: context.id,
                                            old_status_id: old_status_id,
                                            new_status_id: new_status_id,
                                            tracker_id: tracker.id,
                                            role_id: role.id,
                                            kind: 'WorkflowTransition')
                    records << w
                  end
                  w.author = true if rule == 'author'
                  w.assignee = true if rule == 'assignee'
                  w.save if w.changed?
                elsif w
                  if rule == 'always'
                    w.destroy
                  elsif rule == 'author'
                    if w.assignee
                      w.author = false
                      w.save if w.changed?
                    else
                      w.destroy
                    end
                  elsif rule == 'assignee'
                    if w.author
                      w.assignee = false
                      w.save if w.changed?
                    else
                      w.destroy
                    end
                  end
                end
              end
            end
          end
        end
      end
    end
  end
end
