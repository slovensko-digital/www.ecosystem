class Registration
  include ActiveModel::Model
  include ActiveModel::Attributes

  FORM_URL = 'https://docs.google.com/forms/d/e/1FAIpQLScswqdDYxXtjUDW7Crw0aro3Au87R1dVmHIYyA5UH4jrZNZ5g/formResponse'

  REQUEST_MAPPING = {
    email: 'entry.1908289207',
    service: 'entry.1504702132',
    score: 'entry.324492615',
  }.freeze

  attr_accessor :email, :service, :score

  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, on: :submit
  validates :service, inclusion: %w(datahub autoform slovensko_sk_api), on: :render

  def save
    return false unless valid?(:submit)

    if block_given?
      return false unless yield
    end

    RestClient.post(FORM_URL, **build_request_params)
  end

  def build_request_params
    mapping.transform_keys { |attr| send(attr) }.invert.symbolize_keys
  end

  def user_input_fields
    [:email]
  end

  def html_id
    "#{service}_registration_form"
  end

  def mapping
    REQUEST_MAPPING
  end

  private_constant :REQUEST_MAPPING
end
