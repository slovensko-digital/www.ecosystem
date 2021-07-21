module Environment
  extend self

  def api_host
    @host ||= URI.parse(ENV.fetch('DATAHUB_URL')).host
  end
end
