Redmine::Plugin.register :redmine_overwriting_workflows do
  name 'Redmine Overwriting Workflows plugin'
  author 'Maria Syczewska'
  description 'This is a plugin for Redmine for overwriting workflows within the project'
  version '0.0.1'
  url 'https://github.com/efigence/redmine_overwriting_workflows'
  author_url 'https://github.com/efigence'

  permission :manage_workflows, project_workflows: [:edit, :save, :permissions]

  require 'redmine_overwriting_workflows/patches/issue_patch'

  ActionDispatch::Callbacks.to_prepare do
    require 'redmine_overwriting_workflows/patches/issue_status_patch'
    require 'redmine_overwriting_workflows/patches/projects_helper_patch'
  end
end
