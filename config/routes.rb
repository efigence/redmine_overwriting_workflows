# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html

Rails.application.routes.draw do

  get 'projects/:id/project_workflows/edit', :to => 'project_workflows#edit', as: :edit_project_workflow
  get 'projects/:id/project_workflows', :to => 'project_workflows#index', as: :project_workflows
  post 'projects/:id/project_workflows/:role_id/:tracker_id/save', :to => 'project_workflows#save', as: :save_project_workflow
  patch 'projects/:id/project_workflows/:role_id/:tracker_id/save', :to => 'project_workflows#save'
  get 'projects/:id/project_workflows/copy', :to => 'project_workflows#copy', as: :copy_project_workflow

end
