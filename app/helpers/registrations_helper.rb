module RegistrationsHelper
  def recaptcha_action(service = controller_name)
    "#{service}_registration"
  end

  def render_registration_form(service: controller_name, model: nil)
    model ||= Registration.build_from(service: service)

    render partial: 'registrations/form', object: model
  end
end
