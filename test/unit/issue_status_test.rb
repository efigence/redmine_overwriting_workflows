require File.expand_path('../../test_helper', __FILE__)

class IssueStatusTest < ActiveSupport::TestCase
  def test_new_statuses_allowed_to
    WorkflowTransition.delete_all
    WorkflowTransition.create!(role_id: 1,
                               tracker_id: 1,
                               old_status_id: 1,
                               new_status_id: 2,
                               author: false,
                               assignee: false)

    status = IssueStatus.find(1)
    role = Role.find(1)
    tracker = Tracker.find(1)

    assert_equal [2], status.new_statuses_allowed_to([role], tracker, false, false).map(&:id)
    assert_equal [2], status.find_new_statuses_allowed_to([role], tracker, false, false).map(&:id)
  end

  def test_new_statuses_allowed_to_with_project
    WorkflowTransition.delete_all
    WorkflowTransition.create!(role_id: 1,
                               tracker_id: 1,
                               old_status_id: 1,
                               new_status_id: 2,
                               author: false,
                               assignee: false)

    ProjectWorkflow.create!(project_id: 1,
                            workflow_transition_id: 1,
                            role_id: 1,
                            tracker_id: 1,
                            old_status_id: 1,
                            new_status_id: 4,
                            author: false,
                            assignee: false)

    status = IssueStatus.find(1)
    role = Role.find(1)
    tracker = Tracker.find(1)
    project = Project.find(1)

    assert_equal [4], status.new_statuses_allowed_to([role], tracker, false, false, project).map(&:id)
    assert_equal [4], status.find_new_statuses_allowed_to([role], tracker, false, false, project).map(&:id)
  end
end
