class ErrorsController < ContentController

  def not_found
    respond_to do |format|
      format.html do
        @page.title = 'Stránka sa nenašla' # TODO this smells
        render status: 404
      end
      format.json { render json: {error_message: 'Not found', status: 404}, status: 404 }
      format.any { render plain: 'Not found', status: 404, content_type: 'text/plain' }
    end
  end

  def unacceptable
    respond_to do |format|
      format.html do
        @page.title = 'Nepovolená akcia' # TODO this smells
        render status: 422
      end
      format.json { render json: {error_message: 'Change rejected', status: 422}, status: 422 }
    end
  end

  def internal_error
    respond_to do |format|
      format.html do
        @page.title = 'Ups, niečo sa pokazilo' # TODO this smells
        render status: 500
      end
      format.json { render json: {error_message: 'Something went wrong', status: 500}, status: 500 }
    end
  end

end
