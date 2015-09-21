class ProjectWorkflow < ActiveRecord::Base
  unloadable

  belongs_to :workflow

  attr_accessible :project_id,
    :tracker_id,
    :old_status_id,
    :new_status_id,
    :role_id,
    :assignee,
    :author,
    :type,
    :field_name,
    :rule

  # serialize :permissions, ::Role::PermissionsAttributeCoder

  # def roles_permissions
  #   Setting.plugin_overwriting_roles["permissions"]
  # end

  # def setable_permissions
  #   setable_permissions = Array.new
  #   Setting.plugin_redmine_overwriting_roles["permissions"].each do |setting|
  #     setable_permissions += Redmine::AccessControl.permissions.select {|perm| perm.name == setting.to_sym}
  #   end
  #   setable_permissions
  # end

  # def permissions=(perms)
  #   perms = perms.collect {|p| p.to_sym unless p.blank? }.compact.uniq if perms
  #   write_attribute(:permissions, perms)
  # end

end
