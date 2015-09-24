class ProjectWorkflowsController < ApplicationController

  before_filter :find_project
  before_filter :check_permissions

  # def index
  #   @roles = Role.sorted.select(&:consider_workflow?)
  #   @trackers = Tracker.sorted
  #   @workflow_counts = WorkflowTransition.group(:tracker_id, :role_id).count
  #   WorkflowTransition.includes(:project_workflows).each do |workflow|
  #     if workflow.project_workflows.present?
  #       @workflow_counts[[workflow.tracker_id, workflow.role_id]] = ProjectWorkflow
  #           .where(project_id: @project.id, tracker_id: workflow.tracker_id, role_id: workflow.role_id)
  #           .group(:tracker_id, :role_id)
  #           .count.values[0]
  #     end
  #   end
  # end

  def edit
    @workflows = WorkflowTransition.where(tracker_id: params[:tracker_id], role_id: params[:role_id])
    @project_workflows = find_project_workflows || build_project_workflows
  end

  def permissions
  end

  def save
    @workflows = WorkflowTransition.where(tracker_id: params[:tracker_id], role_id: params[:role_id])
    @project_workflows = find_project_workflows || build_project_workflows
    if @project_workflows.save
      flash[:notice] = l(:notice_successful_update)
      redirect_to "/projects/#{@project.id}/settings" # change transitions/permissions
    else
      render :action => 'edit'
    end
  end

  def copy
  end

  private
  def build_project_workflows
    @workflows.each do |workflow|
      ProjectWorkflow.new(workflow.attributes.merge({project_id: @project.id, workflow_transition_id: workflow.id}))
    end
  end

  def find_project_workflows
    @workflows.each do |workflow|
      ProjectWorkflow.where(project_id: @project.id, workflow_transition_id: workflow.id)
    end
  end

  def check_permissions
    unless User.current.admin? || User.current.allowed_to?(:manage_workflows, @project)
      redirect_to home_path
    end
  end
end
