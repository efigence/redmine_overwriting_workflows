module ProjectWorkflowsHelper
  def options_for_workflow_select(name, objects, selected, options = {})
    option_tags = ''.html_safe
    multiple = false
    if selected
      if selected.size == objects.size
        selected = 'all'
      else
        selected = selected.map(&:id)
        multiple = true if selected.size > 1
      end
    else
      selected = objects.first.try(:id)
    end
    all_tag_options = { value: 'all', selected: (selected == 'all') }
    all_tag_options.merge!(style: 'display:none;') if multiple
    option_tags << content_tag('option', l(:label_all), all_tag_options)
    option_tags << options_from_collection_for_select(objects, 'id', 'name', selected)
    select_tag name, option_tags, { multiple: multiple }.merge(options)
  end

  def transition_tag(workflows, old_status, new_status, name)
    w = workflows.count { |w| w.old_status_id == old_status.id && w.new_status_id == new_status.id }

    tag_name = "transitions[#{old_status.id}][#{new_status.id}][#{name}]"
    if w == 0 || w == @roles.size * @trackers.size

      hidden_field_tag(tag_name, '0', id: nil) +
        check_box_tag(tag_name, '1', w != 0,
                      class: "old-status-#{old_status.id} new-status-#{new_status.id}")
    else
      select_tag tag_name,
                 options_for_select([
                   [l(:general_text_Yes), '1'],
                   [l(:general_text_No), '0'],
                   [l(:label_no_change_option), 'no_change']
                 ], 'no_change')
    end
  end
end
