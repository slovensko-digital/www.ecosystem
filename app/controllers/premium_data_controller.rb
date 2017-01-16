class PremiumDataController < ContentController
  def show
    @page.title = 'Premiové dáta &middot; Ekosystém.Slovensko.Digital'.html_safe;
    @page.og.description = 'Prístup ku konsolidovaným a štruktúrovaným dátam. REST a SQL API.'
  end
end
