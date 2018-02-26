class Services::AutoformController < ContentController
  def index
    @page.title = 'Automatické výpĺňanie údajov o firmách. &middot; Autoform'.html_safe
    @page.og.image = view_context.image_url('fb-autoform.png')
    @page.og.description = 'Rýchle vypĺňanie kontaktných a fakturačných údajov o právnických osobách. Vždy aktuálne.'
  end

  def integration_manual
    @page.title = 'Integračný manuál &middot; Autoform'.html_safe
    @page.og.image = view_context.image_url('fb-autoform.png')
    @page.og.description = 'Rýchle vypĺňanie kontaktných a fakturačných údajov o právnických osobách. Vždy aktuálne.'
  end
end
