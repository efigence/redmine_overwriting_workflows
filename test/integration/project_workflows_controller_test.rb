require File.expand_path('../../test_helper', __FILE__)

class ProjectWorkflowsControllerTest < Redmine::IntegrationTest
  fixtures :users, :projects, :roles, :members, :member_roles

  def setup
    @project = projects(:projects_001)
  end

  def test_should_allow_admin_to_see_worfklow_settings
    log_user('admin', 'admin')
    assert_equal true, User.current.allowed_to?(:manage_workflows, @project)

    # get settings_project_path(@project)
    # assert_response :success
    # assert_select '#tab-workflows'

    get edit_project_workflows_path(@project)
    assert_response :success

    get edit_project_workflows_permissions_path(@project)
    assert_response :success
  end

  def test_should_allow_project_manager_to_see_roles_settings
    log_user('jsmith', 'jsmith')
    assert_equal true, User.current.allowed_to?(:manage_workflows, @project)

    # get settings_project_path(@project)
    # assert_response :success
    # assert_select '#tab-workflows'

    get edit_project_workflows_path(@project)
    assert_response :success

    get edit_project_workflows_permissions_path(@project)
    assert_response :success
  end

  def test_should_not_allow_to_see_roles_settings
    log_user('dlopper', 'foo')
    assert_equal false, User.current.allowed_to?(:manage_workflows, @project)

    # get settings_project_path(@project)
    # assert_response :success
    # assert_select '#tab-workflows', false

    get edit_project_workflows_path(@project)
    assert_response :redirect

    get edit_project_workflows_permissions_path(@project)
    assert_response :redirect
  end
end
