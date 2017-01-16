class PremiumApisController < ContentController
  def show
    @page.title = 'Premium API &middot; Ekosystém.Slovensko.Digital'.html_safe
    @page.og.description = 'Prístup ku konsolidovaným dátam. REST a SQL API.'
  end
end
