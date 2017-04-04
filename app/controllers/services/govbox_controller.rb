class Services::GovboxController < ContentController
  def index
    @page.title = 'Jednoduchý prístup k štátnej elektronickej schránke. &middot; GovBox'.html_safe
    @page.og.image = view_context.image_url('fb-govbox.png')
    @page.og.description = 'Jednoduchý prístup k štátnej elektronickej schránke. Bez elektronického občianskeho preukazu, priamo na Váš email.'
  end
end
