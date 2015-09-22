class ProjectWorkflow < ActiveRecord::Base
  unloadable

  belongs_to :workflows, :class_name => 'WorkflowTransition'

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

end
