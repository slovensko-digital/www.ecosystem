Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  namespace :services, path: :sluzby do
    resources :autoform
    resources :datahub
  end

  resource 'open_data', path: 'otvorene-data'
  resource 'open_api', path: 'otvorene-api'

  get 'podmienky', to: 'static#terms', as: :terms

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
end
