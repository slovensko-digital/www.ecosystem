class HomepageController < ContentController
  include ActionView::Helpers::NumberHelper

  before_action :dump_metadata, only: :index

  SCHEMAS = [:crz, :itms, :ov, :rpo, :ruz, :socpoist, :vszp, :vvo]

  def index
    @page.title = 'Služby. Otvorené dáta &amp; API. &middot; Ekosystém.Slovensko.Digital'.html_safe
    @page.og.title = 'Služby. Otvorené dáta &amp; API.'.html_safe
    @page.og.description = 'Lepšie digitálne služby štátu nie sú sci-fi.'
  end

  private

  def dump_metadata
    @dump_urls = SCHEMAS.map do |schema|
      [schema, URI('https://s3.eu-central-1.amazonaws.com/ekosystem-slovensko-digital-dumps/').merge("#{schema}.sql.gz")]
    end.to_h

    @dump_sizes = Rails.cache.fetch('dump_sizes') do
      SCHEMAS.map do |schema|
        size = Net::HTTP.start(@dump_urls[schema].host) { |http| Integer(http.request_head(@dump_urls[schema])['content-length']) rescue nil }
        [schema, size.present? ? "(#{number_to_human_size(size, precision: 2, separator: ',')})" : '(? MB)']
      end.to_h
    end
  end
end
