require File.expand_path('../../test_helper', __FILE__)

class IssuesControllerTest < Redmine::IntegrationTest

  def test_should_see_proper_transitions
    log_user('dlopper', 'foo')

  end

end
