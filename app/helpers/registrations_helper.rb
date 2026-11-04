module RegistrationsHelper
  # How the last registration of the visitor on this page ended; shown once.
  def cap_registration_result(*products)
    result = session[:cap_registration]

    return unless result && products.include?(result['product'])

    session.delete(:cap_registration)
  end
end
