class Services::ConsultationsController < ContentController
  layout 'application_bs4'

  def index
    @page.title = 'Konzultačné služby a analýzy podľa vašich potrieb'.html_safe
    # @page.og.image = view_context.image_url('services/consultations/facebook_share.png')
    @page.og.description = 'Konzultačné služby a analýzy podľa vašich potrieb a individuálneho zadania.'
  end
end
