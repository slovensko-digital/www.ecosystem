module ApplicationHelper
  def api_host
    if Rails.env.staging?
      'datahub.ekosystem.staging.slovensko.digital'
    else
      'datahub.ekosystem.slovensko.digital'
    end
  end
end
