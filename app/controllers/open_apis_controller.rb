class OpenApisController < ContentController
  def show
    @page.title = 'Otvorené API &middot; Ekosystém.Slovensko.Digital'.html_safe
    @page.og.description = 'Prístup k štruktúrovaným dátam. SQL dumpy, REST a SQL API.'
  end
end
