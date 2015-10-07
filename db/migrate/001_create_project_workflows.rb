class CreateProjectWorkflows < ActiveRecord::Migration
  def up
    create_table :project_workflows do |t|
      t.column :project_id, :integer, limit: 4, null: false
      t.column :tracker_id, :integer, limit: 4, default: 0, null: false
      t.column :old_status_id, :integer, limit: 4, default: 0, null: false
      t.column :new_status_id, :integer, limit: 4, default: 0, null: false
      t.column :role_id, :integer, limit: 4, default: 0, null: false
      t.column :assignee, :boolean, limit: 1, default: false, null: false
      t.column :author, :boolean, limit: 1, default: false, null: false
      t.column :kind, :string, limit: 30
      t.column :field_name, :string, limit: 30
      t.column :rule, :string, limit: 30
    end
  end

  def down
    drop_table :project_workflows
  end
end
