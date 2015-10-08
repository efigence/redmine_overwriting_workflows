require File.expand_path('../../test_helper', __FILE__)

class IssuesControllerTest < Redmine::IntegrationTest
  fixtures :projects,
           :users, :email_addresses,
           :roles,
           :members,
           :member_roles,
           :issues,
           :issue_statuses,
           :issue_relations,
           :versions,
           :trackers,
           :projects_trackers,
           :issue_categories,
           :enabled_modules,
           :enumerations,
           :attachments,
           :workflows,
           :custom_fields,
           :custom_values,
           :custom_fields_projects,
           :custom_fields_trackers,
           :time_entries,
           :journals,
           :journal_details,
           :queries,
           :repositories,
           :changesets

  def setup
    @project = projects(:projects_001)
    @issue = issues(:issues_001)
  end

  def test_should_see_proper_transitions
    log_user('dlopper', 'foo')
    assert User.current.members.where(project_id: @project.id).any?
    assert_equal 'Developer', User.current.members.where(project_id: @project.id).first.roles.first.name
    assert_equal 3, @project.issues.count

    get project_path(@project)
    assert_response :success

    get project_issues_path(@project)
    assert_response :success

    get issues_path
    assert_response :success

    # get '/issues/1'
    # assert_response :success

    get issue_path(@issue)
    assert_response :success

  end

end