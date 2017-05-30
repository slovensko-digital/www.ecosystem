class Services::GovboxController < ContentController
  layout 'application_bs4'

  before_action :ensure_live, only: [:index, :register_step1, :faq]

  PARAMS = [
    :legal_subject_name, :cin, :vatin, :formatted_address,
    :given_name, :family_name, :person_formatted_address,
    :email, :phone, :postal_address, :snail_mail,
    :password, :password_confirmation, :ga_user_id, :referral_code,
  ]

  def index
    @page.title = 'Jednoduchý prístup k štátnej elektronickej schránke &middot; GovBox'.html_safe
    @page.og.image = view_context.image_url('services/govbox/facebook_share.png')
    @page.og.description = 'Preposielanie správ zo štátnej elektronickej schránky priamo na Váš email. Bez elektronického občianskeho preukazu, bez prihlasovania. Od Slovensko.Digital.'
  end

  def faq
    @page.title = 'Často kladené otázky &middot; GovBox'.html_safe
    @page.og.image = view_context.image_url('services/govbox/facebook_share.png')
  end

  def register_step1
    @page.title = 'Jednoduchý prístup k štátnej elektronickej schránke &middot; GovBox'.html_safe
    @page.og.image = view_context.image_url('services/govbox/facebook_share.png')
    @page.og.description = 'Preposielanie správ zo štátnej elektronickej schránky priamo na Váš email. Bez elektronického občianskeho preukazu, bez prihlasovania. Od Slovensko.Digital.'
  end

  def register_step2
  end

  def register_step3
  end

  def register_step4
  end

  def register_step5
    begin
      RestClient.post(ENV.fetch('GOVBOX_FORM_ENDPOINT'), params.permit(PARAMS).to_h)
      redirect_to register_thanks_services_govbox_index_path
    rescue RestClient::ExceptionWithResponse => e
      Rollbar.error(e)
      render :register_error
    end
  end

  def register_thanks
  end

  def register_error
  end


  private

  def ensure_live
    unless rollout.active?(:govbox)
      render template: 'errors/not_found', status: 404, layout: 'application'
    end
  end
end
