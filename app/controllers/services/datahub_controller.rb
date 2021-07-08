class Services::DatahubController < ContentController
  include RegistrationsHelper

  def index
    @page.title = 'Vyčistené, štruktúrované dáta nielen o firmách. &middot; Datahub'.html_safe
    @page.og.image = view_context.image_url('fb-datahub.png')
    @page.og.description = 'Prístup ku konsolidovaným a prepojeným štruktúrovaným dátam. Exporty dát do Excelu, rozhranie pre analytické reporty cez SQL.'
  end
end
