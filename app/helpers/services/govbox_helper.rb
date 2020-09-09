module Services::GovboxHelper
  def format_address(statutory_entry)
    Datahub::Utils.build_formatted_address(OpenStruct.new(statutory_entry))
  end
end
