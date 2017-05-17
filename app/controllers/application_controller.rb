class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  helper_method :rollout

  def rollout
    r = Rollout.new
    r.add_feature(:govbox, Time.new(2017, 5, 17, 10, 0, 0))
    r.activate!(params[:rollout].to_sym) if params[:rollout]
    r
  end
end
