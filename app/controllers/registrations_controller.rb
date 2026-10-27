# The registration of Autoform and Datahub (CapRegistrations): the form on the
# page of the service and the page behind the link the client gets by e-mail.
# Opening the link changes nothing (mail scanners open links too), the button
# confirms the registration.
class RegistrationsController < ContentController
  PAGES = {
    'AUTOFORM' => :services_autoform_index_path,
    'DATAHUB_API' => :services_datahub_index_path,
    'DATAHUB_SQL' => :services_datahub_index_path,
  }.freeze

  UNAVAILABLE = 'Registráciu sa nepodarilo odoslať. Skúste to prosím o chvíľu znova alebo nám napíšte na ekosystem@slovensko.digital.'.freeze

  before_action :set_confirmation_page, only: [:confirmation, :confirm]

  def create
    values = params.permit(*CapRegistrations::FIELDS).to_h.transform_values { |value| value.to_s.strip }
    values['product'] = 'AUTOFORM' unless CapRegistrations::PRODUCTS.key?(values['product'])

    # A bot fills in every field, also the hidden one.
    kind, message = params[:website].present? ? ['success', registered_message(values, 'confirmation' => 'MANUAL')] : register(values)

    session[:cap_registration] = { 'product' => values['product'], 'kind' => kind, 'message' => message, 'values' => kind == 'error' ? values : {} }
    redirect_to send(PAGES[values['product']], anchor: 'registracia')
  end

  def confirmation
    @token = params[:t].to_s
  end

  def confirm
    @kind, @message = confirm_registration(params[:t].to_s)
    render :confirmation
  end

  private

  def set_confirmation_page
    @page.title = 'Potvrdenie registrácie &middot; Ekosystém.Slovensko.Digital'.html_safe
  end

  def register(values)
    result = CapRegistrations.register(values)

    case result.status
    when 200 then ['success', registered_message(values, result.body)]
    when 422 then ['error', "Registrácia sa nepodarila: #{result.body['error'] || 'neplatné údaje'}. Opravte prosím údaje a skúste znova."]
    else unavailable("POST /s/registrations returned #{result.status}")
    end
  rescue StandardError => e
    unavailable(e)
  end

  def registered_message(values, body)
    case body['status']
    when 'resent'
      'Registráciu s týmto e-mailom už evidujeme. Poslali sme vám nový e-mail s odkazom na potvrdenie.'
    when 'duplicate'
      'Registráciu s týmto e-mailom už evidujeme. Ozveme sa vám e-mailom.'
    else
      if body['confirmation'] == 'SENT'
        "Ďakujeme. Na #{values['email']} sme poslali e-mail s vašimi údajmi a odkazom, ktorým registráciu potvrdíte."
      else
        'Ďakujeme, registráciu sme prijali. Údaje skontrolujeme a pošleme vám ich e-mailom na potvrdenie.'
      end
    end
  end

  def confirm_registration(token)
    result = CapRegistrations.confirm(token)

    return unavailable("POST /s/registrations/confirm returned #{result.status}") unless result.status == 200

    case result.body['status']
    when 'activating'
      ['success', "Registrácia je potvrdená. Prístupové údaje vám o pár minút pošleme na #{result.body['email'].presence || 'váš e-mail'}."]
    when 'activated'
      ['success', "Registrácia je potvrdená. Prístupové údaje sme poslali na #{result.body['email'].presence || 'váš e-mail'}."]
    when 'pending'
      ['success', 'Ďakujeme, registrácia je potvrdená. Prístupové údaje vám pošleme po kontrole, zvyčajne do jedného pracovného dňa.']
    when 'already_confirmed'
      ['info', 'Registrácia už je potvrdená.']
    else
      ['error', 'Odkaz neplatí alebo vypršal. Zaregistrujte sa prosím znova, pošleme vám nový.']
    end
  rescue StandardError => e
    unavailable(e)
  end

  def unavailable(error)
    Rails.logger.error("CAP registration: #{error}")
    Rollbar.error(error) if error.is_a?(Exception)

    ['error', UNAVAILABLE]
  end
end
