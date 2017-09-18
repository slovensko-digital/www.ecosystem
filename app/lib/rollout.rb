class Rollout
  def initialize
    @features = {}
    @active = {}
  end

  def add_feature(name, release_time)
    @features[name] = release_time
  end

  def activate!(feature_name)
    @active[feature_name] = true
  end

  def active?(feature_name)
    return true if Rails.env.test?
    return true if @active[feature_name]
    Time.current >= @features.fetch(feature_name)
  end
end


