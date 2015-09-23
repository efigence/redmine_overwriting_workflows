module ProjectWorkflowsHelper
  def options_for_workflow_select(name, objects, selected, options={})
    option_tags = ''.html_safe
    multiple = false
    if selected
      if selected.size == objects.size
        selected = 'all'
      else
        selected = selected.map(&:id)
        if selected.size > 1
          multiple = true
        end
      end
    else
      selected = objects.first.try(:id)
    end
    all_tag_options = {:value => 'all', :selected => (selected == 'all')}
    if multiple
      all_tag_options.merge!(:style => "display:none;")
    end
    option_tags << content_tag('option', l(:label_all), all_tag_options)
    option_tags << options_from_collection_for_select(objects, "id", "name", selected)
    select_tag name, option_tags, {:multiple => multiple}.merge(options)
  end
end
