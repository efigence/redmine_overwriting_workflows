class ProjectWorkflowsController < WorkflowsController

  before_filter :find_project
  before_filter :check_permissions
  before_filter :find_trackers_roles_and_statuses_for_edit, only: [:edit, :permissions]

  def edit
    return unless @trackers && @roles && @statuses.any?
    if !find_project_workflows.empty?
      workflows = find_project_workflows
    else
      workflows = create_project_workflows(WorkflowTransition)
    end
    @workflows = {}
    @workflows['always'] = workflows.select { |w| !w.author && !w.assignee }
    @workflows['author'] = workflows.select(&:author)
    @workflows['assignee'] = workflows.select(&:assignee)

    if request.post? && @roles && @trackers && params[:transitions]
      transitions = params[:transitions].deep_dup
      transitions.each do |_old_status_id, transitions_by_new_status|
        transitions_by_new_status.each do |_new_status_id, transition_by_rule|
          transition_by_rule.reject! { |_rule, transition| transition == 'no_change' }
        end
      end
      ProjectWorkflow.replace_workflows(@trackers, @roles, transitions, @project)
      flash[:notice] = l(:notice_successful_update)
      return
    end
  end

  def permissions
    return unless @roles && @trackers
    @fields = (Tracker::CORE_FIELDS_ALL - @trackers.map(&:disabled_core_fields).reduce(:&)).map {|field| [field, l("field_"+field.sub(/_id$/, ''))]}
    @custom_fields = @trackers.map(&:custom_fields).flatten.uniq.sort
    if !find_project_workflows.empty?
      @permissions = find_project_workflows
    else
      @permissions = create_project_workflows(WorkflowPermission)
    end
    @statuses.each {|status| @permissions[status.id] ||= {}}
  end

  private

  def create_project_workflows(type)
    workflows = []
    type.where(role_id: @roles.map(&:id), tracker_id: @trackers.map(&:id)).each do |workflow|
      workflows << ProjectWorkflow.new(workflow.attributes.merge(project_id: @project.id,
        role_id: workflow.role_id,
        tracker_id: workflow.tracker_id))
    end
    workflows
  end

  def find_project_workflows
    ProjectWorkflow.where(project_id: @project.id, role_id: @roles.map(&:id), tracker_id: @trackers.map(&:id))
  end

  def check_permissions
    unless User.current.admin? || User.current.allowed_to?(:manage_workflows, @project)
      redirect_to home_path
    end
  end
end
