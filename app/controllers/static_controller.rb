class StaticController < ContentController
  def datasets_terms
    @page.title = 'Podmienky používania datasetov &middot; Ekosystém.Slovensko.Digital'.html_safe
    @page.og.description = 'Licenciu sme nastavili tak, aby boli podmienky používania úplne minimálne a mohli s dátami v princípe robiť čo chcete. Detailné podmienky v právničtine odporúča prečítať 10 z 10 právnikov.'
  end

  def services_terms
    @page.title = 'Podmienky používania služieb &middot; Ekosystém.Slovensko.Digital'.html_safe
  end

  def pricing
    @page.title = 'Cenník služieb &middot; Ekosystém.Slovensko.Digital'.html_safe
  end
end
