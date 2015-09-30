class ProjectWorkflowsController < ApplicationController

  before_filter :find_project
  before_filter :check_permissions

  def edit
    find_trackers_roles_and_statuses_for_edit

    if @trackers && @roles && @statuses.any?
      unless find_project_workflows.empty?
        workflows = find_project_workflows
      else
        workflows = create_project_workflows
      end
      @workflows = {}
      @workflows['always'] = workflows.select {|w| !w.author && !w.assignee}
      @workflows['author'] = workflows.select {|w| w.author}
      @workflows['assignee'] = workflows.select {|w| w.assignee}
    end
  end

  def save
    byebug
    find_trackers_roles_and_statuses_for_edit
    find_project_workflows
    if request.post? && @roles && @trackers && params[:transitions]
      transitions = params[:transitions].deep_dup
      transitions.each do |old_status_id, transitions_by_new_status|
        transitions_by_new_status.each do |new_status_id, transition_by_rule|
          transition_by_rule.reject! {|rule, transition| transition == 'no_change'}
        end
      end
      ProjectWorkflow.replace_workflows(@trackers, @roles, transitions)
      flash[:notice] = l(:notice_successful_update)
      return
    end
  end

  private
  def create_project_workflows
    workflows = []
    WorkflowTransition.where(role_id: @roles.map(&:id), tracker_id: @trackers.map(&:id)).each do |workflow|
      workflows << ProjectWorkflow.create(workflow.attributes.merge({project_id: @project.id,
        workflow_transition_id: workflow.id,
        role_id: workflow.role_id,
        tracker_id: workflow.tracker_id}))
    end
    return workflows
  end

  def find_project_workflows
    ProjectWorkflow.where(project_id: @project.id, role_id: @roles.map(&:id), tracker_id: @trackers.map(&:id))
  end

  def check_permissions
    unless User.current.admin? || User.current.allowed_to?(:manage_workflows, @project)
      redirect_to home_path
    end
  end

  def find_trackers_roles_and_statuses_for_edit
    find_roles
    find_trackers
    find_statuses
  end

  def find_roles
    ids = Array.wrap(params[:role_id])
    if ids == ['all']
      @roles = Role.sorted.to_a
    elsif ids.present?
      @roles = Role.where(:id => ids).to_a
    end
    @roles = nil if @roles.blank?
  end

  def find_trackers
    ids = Array.wrap(params[:tracker_id])
    if ids == ['all']
      @trackers = Tracker.sorted.to_a
    elsif ids.present?
      @trackers = Tracker.where(:id => ids).to_a
    end
    @trackers = nil if @trackers.blank?
  end

  def find_statuses
    @used_statuses_only = (params[:used_statuses_only] == '0' ? false : true)
    if @trackers && @used_statuses_only
      @statuses = @trackers.map(&:issue_statuses).flatten.uniq.sort.presence
    end
    @statuses ||= IssueStatus.sorted.to_a
  end
end
