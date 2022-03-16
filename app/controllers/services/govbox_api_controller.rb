class Services::GovboxApiController < ContentController
  layout 'application_bs4'

  before_action :ensure_live, only: [:index]
  before_action :set_up_footer_template

  def index
    @page.title = 'Správy zo slovensko.sk integrované na interný systém &middot; GovBox API'.html_safe
    @page.og.image = view_context.image_url('services/govbox_api/facebook_share.png')
    @page.og.description = 'Ideálne riešenie pre firmy, ktoré intenzívne využívajú schránku na slovensko.sk, potrebujú zasielať hromadné podania alebo uvažujú o automatizácii procesov. Od Slovensko.Digital.'
  end

  def terms
    @page.title = 'Všeobecné obchodné podmienky &middot; GovBox API'.html_safe
    @page.og.image = view_context.image_url('services/govbox_api/facebook_share.png')
  end

  private

  def ensure_live
    unless rollout.active?(:govbox)
      render template: 'errors/not_found', status: 404, layout: 'application'
    end
  end
  
  def set_up_footer_template
    @footer_template = 'services/govbox/footer'
  end
end
