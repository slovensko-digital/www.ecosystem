class ContentController < ApplicationController
  if ENV['SITE_PASSWORD'].present?
    http_basic_authenticate_with name: 'admin', password: ENV['SITE_PASSWORD']
  end

  before_action :set_page

  def set_page
    @page = OpenStruct.new(
      url: request.protocol + request.host_with_port + request.path,
      og: OpenStruct.new(
        image: view_context.image_url('fb-ekosystem.png'),
        description: 'Služby. Otvorené API. Otvorené dáta.'
      )
    )
  end
end
