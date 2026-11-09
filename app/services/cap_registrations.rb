# Registrations of Autoform and Datahub go to CAP (CRM, Admin, Podpora) of
# Slovensko.Digital: the server sends them with the shared secret, CAP keeps
# the client and the billing data and sends the e-mail with the link to
# confirm. Without CAP_URL and CAP_REGISTRATION_SECRET the pages keep the
# Google Forms.
class CapRegistrations
  PRODUCTS = {
    'AUTOFORM' => 'Autoform',
    'DATAHUB_API' => 'Datahub API',
    'DATAHUB_SQL' => 'Datahub SQL',
  }.freeze

  FIELDS = %w[product email domain company_name ico without_ico street postcode city country].freeze

  Result = Struct.new(:status, :body)

  class << self
    def enabled?
      ENV['CAP_URL'].present? && ENV['CAP_REGISTRATION_SECRET'].present?
    end

    # The billing data of the company of the IČO in the register (Autoform), nil
    # when the register does not know it. The client gives only the IČO, we have the rest.
    def billing_by_ico(ico)
      response = RestClient::Resource.new("#{ENV.fetch('AUTOFORM_URL')}/api/corporate_bodies/search", timeout: 10).get(params: { q: "cin:#{ico}", private_access_token: ENV.fetch('AUTOFORM_PRIVATE_ACCESS_TOKEN') })
      corporate_body = JSON.parse(response.body).first
      return unless corporate_body

      {
        companyName: corporate_body['name'],
        ico: corporate_body['cin'],
        dic: corporate_body['tin'],
        icDph: corporate_body['vatin'],
        street: corporate_body['formatted_street'],
        postcode: corporate_body['postal_code'],
        city: corporate_body['municipality'],
        country: corporate_body['country'],
      }
    end

    # The billing data as written by a client without a Slovak IČO (a person, a
    # foreign company); CAP leaves such a registration to a human.
    def billing_as_written(values)
      { companyName: values['company_name'], street: values['street'], postcode: values['postcode'], city: values['city'], country: values['country'] }
    end

    def register(values, billing)
      post('/s/registrations', product: values['product'], email: values['email'], domain: values['domain'], **billing, source: 'WEB_FORM')
    end

    def confirm(token)
      post('/s/registrations/confirm', token: token)
    end

    private

    def post(path, payload)
      response = RestClient::Request.execute(
        method: :post,
        url: URI.join(ENV.fetch('CAP_URL'), path).to_s,
        payload: payload.to_json,
        headers: { content_type: :json, accept: :json, 'x-registration-secret' => ENV.fetch('CAP_REGISTRATION_SECRET') },
        timeout: 60
      )

      Result.new(response.code, parse(response.body))
    rescue RestClient::ExceptionWithResponse => e
      raise unless e.response

      Result.new(e.http_code, parse(e.response.body))
    end

    def parse(body)
      JSON.parse(body.to_s)
    rescue JSON::ParserError
      {}
    end
  end
end
