Rails.application.routes.draw do
  namespace :services, path: :sluzby do
    resources :govbox do
      collection do
        get :faq, path: 'casto-kladene-otazky'
        get :register_step1, path: 'registracia'
        post :register_step2, path: 'registracia-statutar'
        post :register_step3, path: 'registracia-nastavenie'
        post :register_step4, path: 'registracia-zabezpecenie'
        post :register_step5, path: 'registracia-odoslanie'
        get :register_thanks, path: 'registracia-uspesna'

        get :terms, path: 'vseobecne-obchodne-podmienky'
        get :terms_v1, path: 'vseobecne-obchodne-podmienky-v1'
        get :terms_v2, path: 'vseobecne-obchodne-podmienky-v2'
        get :service_provider, path: 'prevadzkovatel'
        get :pricing, path: 'cennik'
        get :pricing_v1, path: 'cennik-v1'

        # redirects
        get 'registracia-statutar', to: 'govbox#back_to_step1'
        get 'registracia-nastavenie', to: 'govbox#back_to_step1'
        get 'registracia-zabezpecenie', to: 'govbox#back_to_step1'
        get 'registracia-odoslanie', to: 'govbox#back_to_step1'
        get 'ochrana-osobnych-udajov', to: '/static#privacy_policy'
      end
    end

    resources :autoform do
      collection do
        get :integration_manual, path: 'integracny-manual'
      end
    end

    resources :datahub
  end

  resource 'open_data', path: 'otvorene-data'
  resource 'open_api', path: 'otvorene-api'

  resource 'premium_data', path: 'premiove-data'
  resource 'premium_api', path: 'premiove-api'

  get 'podmienky', to: 'static#datasets_terms', as: :datasets_terms
  get 'podmienky-v1', to: 'static#datasets_terms_v1', as: :datasets_terms_v1
  get 'podmienky-sluzieb', to: 'static#services_terms', as: :services_terms
  get 'cennik', to: 'static#pricing', as: :pricing
  get 'ochrana-osobnych-udajov', to: 'static#privacy_policy', as: :privacy_policy

  namespace :health do
    get :all_env_set
    get :services

    get '/' => :services
  end

  root to: 'homepage#index'

  get '404', to: 'errors#not_found'
  get '422', to: 'errors#unacceptable'
  get '500', to: 'errors#internal_error'

  # redirect all /api request to to datahub.ekosystem
  match '/api/(*endpoint)', to: redirect(host: 'datahub.ekosystem.slovensko.digital'), via: :all

  # backward compatibility for generating url in views
  concern :syncable do
    get :sync, on: :collection
  end

  namespace :api, defaults: {format: 'json'} do
    namespace :datahub do # TODO move to open_data namespace when ready (breaking change!)
      resources :corporate_bodies, concerns: :syncable do
        get :search, on: :collection
      end
    end

    namespace :data do
      namespace :crz do
        resources :contracts, concerns: :syncable
      end

      namespace :rpo do
        resources :organizations, concerns: :syncable
      end

      namespace :ruz do
        resources :accounting_entities, concerns: :syncable
      end

      namespace :ov do
        resources :bulletin_issues, concerns: :syncable
        resources :raw_issues, concerns: :syncable
        resources :or_podanie_issues, concerns: :syncable
        resources :konkurz_restrukturalizacia_issues, concerns: :syncable
        resources :konkurz_vyrovnanie_issues, concerns: :syncable
        resources :likvidator_issues, concerns: :syncable
        resources :znizenie_imania_issues, concerns: :syncable
      end

      namespace :vvo do
        resources :raw_notices, concerns: :syncable
        resources :notices, concerns: :syncable
      end

      namespace :socpoist do
        resources :debtors, concerns: :syncable
        resources :debts_lists, concerns: :syncable
      end

      namespace :vszp do
        resources :debtors, concerns: :syncable
        resources :debts_lists, concerns: :syncable
      end
    end

    namespace :autoform do # TODO move to separate app
      resources :corporate_bodies do
        get :search, on: :collection
      end
    end
  end

  get 'apple-touch-icon', to: 'errors#not_found'
  get 'apple-touch-icon-precomposed', to: 'errors#not_found'
  get 'apple-touch-icon-120x120', to: 'errors#not_found'
  get 'apple-touch-icon-120x120-precomposed', to: 'errors#not_found'
end
