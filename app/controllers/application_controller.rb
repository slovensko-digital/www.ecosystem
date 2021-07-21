class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  before_action :store_referral

  def rollout
    r = Rollout.new
    r.add_feature(:govbox, Time.new(2017, 5, 18, 10, 0, 0))
    r.activate!(params[:rollout].to_sym) if params[:rollout]
    r
  end
  helper_method :rollout

  def api_host
    Environment.api_host
  end
  helper_method :api_host

  def store_referral
    if params[:ref]
      cookies[:ref] = { value: params[:ref], expires: 30.days.from_now }
    end
  end
end
