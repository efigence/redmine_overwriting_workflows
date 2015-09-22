require File.expand_path('../../test_helper', __FILE__)

class ProjectRoleTest < ActiveSupport::TestCase
  fixtures :users, :trackers, :roles, :workflows, :issue_statuses, :project_workflows

  def test_should_check_workflows_without_context
  end

  def test_should_check_workflows_in_project_context
  end

end
