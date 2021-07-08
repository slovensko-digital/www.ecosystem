module RegistrationsHelper
  def registration_form_id(service = controller_name)
    "#{service}_registration_form"
  end

  def recaptcha_action
    "#{controller_name}_registration"
  end

  def controller_specific_register_path
    polymorphic_path([:services, controller_name, :index])
  end

  def render_registration_form(service: controller_name, registration: nil)
    registration ||= Registration.new(service: service)

    if registration.valid?(:render)
      render partial: 'registrations/form', object: registration
    end
  end

  def translate_field(field_name)
    translate "registrations.#{field_name}", default: ''
  end
end
