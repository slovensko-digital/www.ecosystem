class HomepageController < ContentController
  before_action :fetch_dump_sizes, only: :index

  def index
    @page.title = 'Služby. Otvorené dáta &amp; API. &middot; Ekosystém.Slovensko.Digital'.html_safe
    @page.og.title = 'Služby. Otvorené dáta &amp; API.'.html_safe
    @page.og.description = 'Lepšie digitálne služby štátu nie sú sci-fi.'
  end

  private

  def fetch_dump_sizes
    uri = URI('https://s3.eu-central-1.amazonaws.com/ekosystem-slovensko-digital-dumps/')

    @dump_sizes = Rails.cache.fetch('dump_sizes') do
      DEFAULT_DUMP_SIZES.map do |schema_name, default_size|
        size = Net::HTTP.start(uri.host) { |http| (Integer(http.request_head(URI.join(uri, "#{schema_name}.sql.gz"))['content-length']) / 1_000_000).ceil rescue default_size }
        [schema_name, "(#{size} MB)"]
      end.to_h
    end
  end

  DEFAULT_DUMP_SIZES = {
    rpo: 1500,
    itms: 420,
    vvo: 460,
    ov: 2400,
    ruz: 110,
    socpoist: 5,
    vszp: 6,
    crz: 320
  }
end
