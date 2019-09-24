module ApplicationHelper
  def api_host
    if Rails.env.staging?
      'datahub.ekosystem.staging.slovensko.digital'
    else
      'datahub.ekosystem.slovensko.digital'
    end
  end

  def toggle_switch_tag(name, value = '1', _class = nil, opts = {})
    content_tag 'label', (check_box_tag name, value) + '<div></div>'.html_safe, class: "switch #{_class}", **opts.except(:class)
  end
end
