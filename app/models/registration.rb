class Registration
  include ActiveModel::Model
  include ActiveModel::Attributes

  SUBMIT_MAPPINGS = HashWithIndifferentAccess.new(
    autoform: {
      url: 'https://docs.google.com/forms/d/1TpYNJfBQVGt4lmKP-wrXGkok2bo-Y6mzpmeUsJTnRis/formResponse',
      email: 'entry.204431983',
      other: { domain: 'entry.1349114640' }
    },
    slovensko_sk_api: {
      url: 'https://docs.google.com/forms/d/e/1FAIpQLSfUuAjnqGjDvSc-Miy6bP0xODXsjr6g04hGAeYlYkJo-3Iu1Q/formResponse',
      email: 'emailAddress',
    },
    datahub: {
      url: 'https://docs.google.com/forms/d/e/1FAIpQLSdgW4Hf2fEhX3cpTkoYJTaIVs8pWrTFrItt9Hj_9ZD36yPLZQ/formResponse',
      email: 'entry.1902802364',
    }
  )

  attr_accessor :email, :service, :other_fields
  attribute :checkbox_captcha, :boolean, default: false

  validates :service, inclusion: SUBMIT_MAPPINGS.keys, on: :render
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP, message: 'Zadajte email v správnom tvare' }, on: :submit
  # validates :other_fields, each: { presence: true }, on: :submit

  def mappings
    data[:other].reverse_merge(email: data[:email])
  end

  def finish
    args = attributes.transform_keys { |key| mappings[key] }.symbolize_keys!

    RestClient.post(data[:url], **args)
  end

  private

  def checkbox_captcha!
    checkbox_captcha = true
  end

  def data
    SUBMIT_MAPPINGS[service]
  end

  def attributes
    other_fields.reverse_merge(email: email)
  end
end
