module RegistrationsHelper
  def recaptcha_action(service = controller_name)
    "#{service}_registration"
  end

  def new_registration(args)
    raise unless args[:service]

    klass = (args[:service] == 'autoform') ? AutoformRegistration : Registration
    klass.new(args)
  end

  def render_registration_form(service: controller_name, model: nil)
    unless model
      model = new_registration(service: service)
      return if model.invalid?(:render)
    end

    render partial: 'registrations/form', object: model
  end
end
