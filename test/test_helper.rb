# Load the Redmine helper
require File.expand_path(File.dirname(__FILE__) + '/../../../test/test_helper')

class ActionController::TestCase
  fx = [:roles, :issues]
  ActiveRecord::FixtureSet.create_fixtures(File.dirname(__FILE__) + '/fixtures/', fx)
end
