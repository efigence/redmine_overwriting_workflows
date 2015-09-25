require File.expand_path('../../test_helper', __FILE__)

class IssueStatusTest < ActiveSupport::TestCase
  fixtures :projects, :users, :members, :member_roles, :roles,
           :groups_users,
           :trackers, :projects_trackers,
           :enabled_modules,
           :versions,
           :issue_statuses, :issue_categories, :issue_relations, :workflows,
           :enumerations,
           :issues, :journals, :journal_details,
           :custom_fields, :custom_fields_projects, :custom_fields_trackers, :custom_values

  def test_new_statuses_allowed_to
    WorkflowTransition.delete_all

    WorkflowTransition.create!(role_id: 1, tracker_id: 1, old_status_id: 1, new_status_id: 2, author: false, assignee: false)
    WorkflowTransition.create!(role_id: 1, tracker_id: 1, old_status_id: 1, new_status_id: 3, author: true, assignee: false)
    WorkflowTransition.create!(role_id: 1, tracker_id: 1, old_status_id: 1, new_status_id: 4, author: false, assignee: true)
    WorkflowTransition.create!(role_id: 1, tracker_id: 1, old_status_id: 1, new_status_id: 5, author: true, assignee: true)
    status = IssueStatus.find(1)
    role = Role.find(1)
    tracker = Tracker.find(1)

    assert_equal [2], status.new_statuses_allowed_to([role], tracker, false, false).map(&:id)
    assert_equal [2], status.find_new_statuses_allowed_to([role], tracker, false, false).map(&:id)

    assert_equal [2, 3, 5], status.new_statuses_allowed_to([role], tracker, true, false).map(&:id)
    assert_equal [2, 3, 5], status.find_new_statuses_allowed_to([role], tracker, true, false).map(&:id)

    assert_equal [2, 4, 5], status.new_statuses_allowed_to([role], tracker, false, true).map(&:id)
    assert_equal [2, 4, 5], status.find_new_statuses_allowed_to([role], tracker, false, true).map(&:id)

    assert_equal [2, 3, 4, 5], status.new_statuses_allowed_to([role], tracker, true, true).map(&:id)
    assert_equal [2, 3, 4, 5], status.find_new_statuses_allowed_to([role], tracker, true, true).map(&:id)
  end
end
