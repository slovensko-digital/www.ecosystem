class Services::SlovenskoSkApiController < ContentController
  def index
    @page.title = 'Integrácia na slovensko.sk &middot; slovensko.sk API'.html_safe
    @page.og.description = 'Integrácia na slovensko.sk, prihlasovanie pomocou eID, automatizované zasielanie podaní cez REST API. Docker kontajner. Open Source.'
  end
end
