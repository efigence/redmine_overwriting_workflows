require File.expand_path('../../test_helper', __FILE__)

class IssueTest < ActiveSupport::TestCase
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
    user = User.find(2)
    issue = Issue.generate!(tracker: tracker,
                            status: status,
                            project_id: 1,
                            author_id: 1)

    assert_equal [1, 2], issue.new_statuses_allowed_to(user).map(&:id)
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
                            role_id: 1,
                            tracker_id: 1,
                            old_status_id: 1,
                            new_status_id: 4,
                            author: false,
                            assignee: false)

    status = IssueStatus.find(1)
    role = Role.find(1)
    tracker = Tracker.find(1)
    user = User.find(2)
    project = Project.find(1)
    issue = Issue.generate!(tracker: tracker,
                            status: status,
                            project_id: 1,
                            author_id: 1)

    assert_equal [1, 4], issue.new_statuses_allowed_to(user, false, project).map(&:id)
  end
end
