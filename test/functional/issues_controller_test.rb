require File.expand_path('../../test_helper', __FILE__)

class IssuesControllerTest < ActionController::TestCase
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

  include Redmine::I18n

  def setup
    User.current = nil
  end

  def test_show_by_developer
    @request.session[:user_id] = 3
    get :show, :id => 1
    byebug
    assert_response :success
    # assert_select 'a', :text => /Quote/
    # assert_select 'form#issue-form' do
    #   assert_select 'fieldset' do
    #     assert_select 'legend', :text => 'Change properties'
    #     assert_select 'input[name=?]', 'issue[subject]'
    #   end
    #   assert_select 'fieldset' do
    #     assert_select 'legend', :text => 'Log time'
    #     assert_select 'input[name=?]', 'time_entry[hours]'
    #   end
    #   assert_select 'fieldset' do
    #     assert_select 'legend', :text => 'Notes'
    #     assert_select 'textarea[name=?]', 'issue[notes]'
    #   end
    # end
  end
end
