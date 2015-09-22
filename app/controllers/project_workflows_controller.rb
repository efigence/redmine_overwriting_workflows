class ProjectWorkflowsController < ApplicationController

  before_filter :check_permissions

  def index
    @roles = Role.sorted.select(&:consider_workflow?)
    @trackers = Tracker.sorted
    @workflow_counts = WorkflowTransition.group(:tracker_id, :role_id).count
  end

  def edit
    @workflows = WorkflowTransition.where(tracker_id: params[:tracker_id], role_id: params[:role_id])
    @project_workflows = find_project_workflows || build_project_workflows
  end

  private
  def build_project_workflows
    @workflows.each do |workflow|
      ProjectWorkflow.new(workflow.attributes.merge({project_id: @project.id, workflow_transition_id: workflow.id}))
    end
  end

  def find_project_workflows
    @workflows.each do |workflow|
      project_workflows.where(project_id: @project.id, workflow_transition_id: workflow.id)
    end
  end

  def check_permissions
    unless User.current.admin? || User.current.allowed_to?(:manage_workflows, @project)
      redirect_to home_path
    end
  end
end
