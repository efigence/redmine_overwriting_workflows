# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html

Rails.application.routes.draw do
  get 'projects/:id/project_workflows', to: 'project_workflows#edit',
                                        as: :edit_project_workflows
  get 'projects/:id/project_workflows/permissions', to: 'project_workflows#permissions',
                                                    as: :edit_project_workflows_permissions
  post 'projects/:id/project_workflows', to: 'project_workflows#save',
                                         as: :save_project_workflows
  post 'projects/:id/project_workflows/permissions', to: 'project_workflows#save_permissions',
                                                     as: :save_project_workflows_permissions
  patch 'projects/:id/project_workflows', to: 'project_workflows#save'
  patch 'projects/:id/project_workflows/permissions', to: 'project_workflows#save_permissions'
end
