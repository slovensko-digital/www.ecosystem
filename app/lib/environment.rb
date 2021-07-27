module Environment
  def self.api_host
    @host ||= URI.parse(ENV.fetch('DATAHUB_URL')).host
  end
end
