module ApplicationHelper
  def api_host
    if Rails.env.staging?
      'datahub.ekosystem.staging.slovensko.digital'
    else
      'datahub.ekosystem.slovensko.digital'
    end
  end

  def required_label_mark
    content_tag :span, '*', class: 'required-label-mark'
  end
end
