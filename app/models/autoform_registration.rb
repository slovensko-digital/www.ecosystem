class AutoformRegistration < Registration
  EXTRA_FIELDS = { domain: 'entry.591019594' }.freeze

  attr_accessor :domain
  validates :domain, presence: true, on: :submit

  def user_input_fields
    super.append(:domain)
  end

  def mapping
    super.merge(EXTRA_FIELDS)
  end
end
