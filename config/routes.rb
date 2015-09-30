# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html

Rails.application.routes.draw do

  post 'projects/:id/project_workflows', :to => 'project_workflows#edit', as: :project_workflows
  get 'projects/:id/project_workflows', :to => 'project_workflows#edit', as: :edit_project_workflows
  get 'projects/:id/project_workflows/permissions', :to => 'project_workflows#permissions', as: :edit_project_workflows_permissions
  post 'projects/:id/project_workflows/:role_id/:tracker_id/save', :to => 'project_workflows#save', as: :save_project_workflows
  patch 'projects/:id/project_workflows/:role_id/:tracker_id/save', :to => 'project_workflows#save'
  get 'projects/:id/project_workflows/copy', :to => 'project_workflows#copy', as: :copy_project_workflows

end
