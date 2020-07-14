class HomepageController < ContentController
  include ActionView::Helpers::NumberHelper

  before_action :fetch_dump_sizes, only: :index

  DUMPS_URL = 'https://s3.eu-central-1.amazonaws.com/ekosystem-slovensko-digital-dumps/'

  def index
    @page.title = 'Služby. Otvorené dáta &amp; API. &middot; Ekosystém.Slovensko.Digital'.html_safe
    @page.og.title = 'Služby. Otvorené dáta &amp; API.'.html_safe
    @page.og.description = 'Lepšie digitálne služby štátu nie sú sci-fi.'
    @url = DUMPS_URL
  end

  private

  def fetch_dump_sizes
    uri = URI(DUMPS_URL)

    @dump_sizes = Rails.cache.fetch('dump_sizes') do
      SCHEMAS.map do |schema_name|
        size = Net::HTTP.start(uri.host) { |http| Integer(http.request_head(URI.join(uri, "#{schema_name}.sql.gz"))['content-length']) rescue nil }
        [schema_name, size.present? ? "(#{number_to_human_size(size, precision: 2, separator: ',')})" : '(? MB)']
      end.to_h
    end
  end

  SCHEMAS = [:rpo, :itms, :vvo, :ov, :ruz, :socpoist, :vszp, :crz]
end
