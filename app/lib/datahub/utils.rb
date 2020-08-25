module Datahub::Utils
  extend self

  def build_formatted_address(cb)
    [build_formatted_street(cb), build_formatted_municipality(cb)].compact.join(', ').presence
  end

  def build_formatted_municipality(cb)
    [cb.postal_code.presence, cb.municipality.presence].compact.join(' ').presence
  end

  def build_formatted_street(cb)
    [cb.street.presence, build_street_number(cb)].compact.join(' ').presence
  end

  def build_street_number(cb)
    [cb.reg_number.presence, cb.building_number.presence].compact.join('/').presence
  end
end
