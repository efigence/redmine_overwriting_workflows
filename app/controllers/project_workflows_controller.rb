class ProjectWorkflowsController < WorkflowsController

  before_filter :find_project
  before_filter :check_permissions
  before_filter :create_project_workflows, only: [:save]

  def edit
    find_trackers_roles_and_statuses_for_edit

    if @trackers && @roles && @statuses.any?
      unless ProjectWorkflow.where(project_id: @project.id).empty?
        workflows = ProjectWorkflow.where(project_id: @project.id, :role_id => @roles.map(&:id), :tracker_id => @trackers.map(&:id))
      else
        workflows = WorkflowTransition.where(:role_id => @roles.map(&:id), :tracker_id => @trackers.map(&:id))
      end
      @workflows = {}
      @workflows['always'] = workflows.select {|w| !w.author && !w.assignee}
      @workflows['author'] = workflows.select {|w| w.author}
      @workflows['assignee'] = workflows.select {|w| w.assignee}
    end
  end

  def save
    @project_workflow = ProjectWorkflow.find(params[:project_workflow_id])
    if request.post? && @roles && @trackers && params[:transitions]
      transitions = params[:transitions].deep_dup
      transitions.each do |old_status_id, transitions_by_new_status|
        transitions_by_new_status.each do |new_status_id, transition_by_rule|
          transition_by_rule.reject! {|rule, transition| transition == 'no_change'}
        end
      end
      # unless ProjectWorkflow.where(project_id: @project.id).empty?
        ProjectWorkflow.replace_workflows(@trackers, @roles, transitions)
      # else
        # WorkflowPermission.replace_workflows(@trackers, @roles, transitions)
      # end
      flash[:notice] = l(:notice_successful_update)
      return
    end
  end

  def copy
  end

  private
  def create_project_workflows
    if ProjectWorkflow.where(project_id: @project.id).empty?
      WorkflowTransition.find_each do |workflow|
        ProjectWorkflow.create(workflow.attributes.merge({project_id: @project.id,
                                  workflow_transition_id: workflow.id,
                                  role_id: workflow.role_id,
                                  tracker_id: workflow.tracker_id}))
      end
    end
  end

  def check_permissions
    unless User.current.admin? || User.current.allowed_to?(:manage_workflows, @project)
      redirect_to home_path
    end
  end
end
