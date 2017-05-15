class Services::GovboxController < ContentController
  layout 'application_bs4'

  PARAMS = [
    :legal_subject_name, :cin, :formatted_address,
    :given_name, :family_name, :pin, :person_formatted_address,
    :email, :phone, :postal_address, :snail_mail,
    :password, :password_confirmation
  ]

  def index
    @page.title = 'Jednoduchý prístup k štátnej elektronickej schránke. &middot; GovBox'.html_safe
    @page.og.image = view_context.image_url('fb-govbox.png')
    @page.og.description = 'Jednoduchý prístup k štátnej elektronickej schránke. Bez elektronického občianskeho preukazu, priamo na Váš email.'
  end

  def register_step1; end

  def register_step2; end

  def register_step3; end

  def register_step4; end

  def register_step5
    RestClient.post(ENV.fetch('GOVBOX_FORM_ENDPOINT'), params.permit(PARAMS).to_h)
    redirect_to register_thanks_services_govbox_index_path
  end

  def register_thanks; end
end
