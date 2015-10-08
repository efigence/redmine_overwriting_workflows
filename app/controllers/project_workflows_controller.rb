class ProjectWorkflowsController < WorkflowsController

  skip_before_filter :require_admin
  before_filter :find_project
  before_filter :check_permissions
  before_filter :find_trackers_roles_and_statuses_for_edit, only: [:edit, :save, :permissions]

  def edit
    return unless @trackers && @roles && @statuses.any?
    if !find_project_workflows.empty?
      workflows = find_project_workflows
    else
      workflows = create_project_workflows
    end
    @workflows = {}
    @workflows['always'] = workflows.select { |w| !w.author && !w.assignee }
    @workflows['author'] = workflows.select(&:author)
    @workflows['assignee'] = workflows.select(&:assignee)
  end

  def save
    if @roles && @trackers && params[:transitions]
      transitions = params[:transitions].deep_dup
      transitions.each do |_old_status_id, transitions_by_new_status|
        transitions_by_new_status.each do |_new_status_id, transition_by_rule|
          transition_by_rule.reject! { |_rule, transition| transition == 'no_change' }
        end
      end
      ProjectWorkflow.replace_workflows(@trackers, @roles, transitions, @project)
      flash[:notice] = l(:notice_successful_update)
    end

    redirect_to edit_project_workflows_path(role_id: @roles, tracker_id: @trackers)
  end

  def permissions
    return unless @roles && @trackers
    @fields = (Tracker::CORE_FIELDS_ALL - @trackers.map(&:disabled_core_fields).reduce(:&)).map {|field| [field, l("field_"+field.sub(/_id$/, ''))]}
    @custom_fields = @trackers.map(&:custom_fields).flatten.uniq.sort
    @permissions = find_project_workflow_permissions
    @statuses.each {|status| @permissions[status.id] ||= {}}

    if request.post? && @roles && @trackers && params[:permissions]
      permissions = params[:permissions].deep_dup
      permissions.each { |field, rule_by_status_id|
        rule_by_status_id.reject! {|status_id, rule| rule == 'no_change'}
      }
      ProjectWorkflow.replace_workflow_permissions(@trackers, @roles, permissions, @project)
      flash[:notice] = l(:notice_successful_update)
      return
    end
  end

  private

  def create_project_workflows
    workflows = []
    WorkflowTransition.where(role_id: @roles.map(&:id), tracker_id: @trackers.map(&:id)).each do |workflow|
      workflows << ProjectWorkflow.new(project_id: @project.id,
        tracker_id: workflow.tracker_id,
        old_status_id: workflow.old_status_id,
        new_status_id: workflow.new_status_id,
        role_id: workflow.role_id,
        assignee: workflow.assignee,
        author: workflow.author,
        kind: "WorkflowTransition",
        field_name: workflow.field_name,
        rule: workflow.rule)
    end
    workflows
  end

  def find_project_workflows(type = WorkflowTransition)
    ProjectWorkflow.where(project_id: @project.id, kind: type, role_id: @roles.map(&:id), tracker_id: @trackers.map(&:id))
  end

  def find_project_workflow_permissions
    find_project_workflows(WorkflowPermission).rules_by_status_id(@trackers, @roles)
  end

  def check_permissions
    unless User.current.admin? || User.current.allowed_to?(:manage_workflows, @project)
      redirect_to home_path
    end
  end
end
