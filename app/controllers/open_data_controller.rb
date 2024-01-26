class OpenDataController < ContentController
  def show
    @page.title = 'Otvorené dáta &middot; Ekosystém.Slovensko.Digital'.html_safe;
    @page.og.description = 'Prístup k štruktúrovaným dátam. SQL dumpy, REST a SQL API.'
  end
end
