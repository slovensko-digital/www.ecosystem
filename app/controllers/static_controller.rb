class StaticController < ContentController
  def datasets_terms
    @page.title = 'Podmienky používania datasetov &middot; Ekosystém.Slovensko.Digital'.html_safe
    @page.og.description = 'Licenciu sme nastavili tak, aby boli podmienky používania úplne minimálne a mohli s dátami v princípe robiť čo chcete. Detailné podmienky v právničtine odporúča prečítať 10 z 10 právnikov.'
  end

  alias datasets_terms_v1 datasets_terms
  alias datasets_terms_v2 datasets_terms

  def services_terms
    @page.title = 'Podmienky používania služieb &middot; Ekosystém.Slovensko.Digital'.html_safe
  end

  def pricing
    @page.title = 'Cenník služieb &middot; Ekosystém.Slovensko.Digital'.html_safe
  end

  def privacy_policy
    @page.title = 'Informácie o spracúvaní osobných údajov &middot; Ekosystém.Slovensko.Digital'.html_safe
  end

  def release_notes
    @page.title = 'Poznámky k zmenám funkcionality a štruktúry dát &middot; Ekosystém.Slovensko.Digital'.html_safe
  end
end
