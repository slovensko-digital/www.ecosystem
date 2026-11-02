# Upgrade na Ruby 4.0 / Rails 8.1 a odstránenie Redisu

## Zámer

Aplikácia beží na nepodporovanom Ruby 2.7.8 a Rails 5.2.4.4. Cieľom je dostať ju na aktuálne
stabilné verzie a zjednodušiť prevádzku odstránením Redisu, ktorý slúži len na jeden cache kľúč.
Výsledkom má byť jeden kontajner (web) + Postgres na staging aj production v GitLabe.

## Ciele

- Ruby **4.0.9** (`.ruby-version`, `Gemfile`, `Dockerfile`).
- Rails **8.1.4** s `config.load_defaults 8.1`.
- Žiadny Redis: gem, konfigurácia, `REDIS_URL`, CI služba.
- Jeden kontajner – už platí (Procfile aj auto-deploy majú len `web`), musí to tak ostať.
- `bundle exec rspec` prejde, `assets:precompile` a docker build prejdú.

## Ne-ciele

- GoodJob ani žiadne ActiveJob joby (ActiveJob ostáva vypnutý).
- Propshaft, importmap, Turbo – asset pipeline ostáva na Sprockets.
- Upgrade Bootstrapu 3/4, jQuery, Turbolinks.
- Upgrade Postgresu v CI alebo na serveroch.

## Anti-ciele (zlyhanie, aj keby to technicky fungovalo)

- Akákoľvek viditeľná alebo funkčná zmena na stránkach.
- Nové tabuľky alebo migrácie v DB – databáza vyzerá ako zdieľaná `datahub` DB.
- Nové povinné ENV premenné na staging/production.

## Obmedzenia

- DB schéma je `db/structure.sql` (`schema_format = :sql`), modely čítajú `pg_catalog`.
- GitLab Auto DevOps builduje z `Dockerfile`, port cez `PORT` (5000), limit pamäte 400Mi,
  health checky v `CHECKS`.
- Nikto pred Pumou neservíruje statické súbory – doteraz to robil `rails_12factor`
  (static files + logovanie na STDOUT). Po jeho odstránení to musí zabezpečiť Rails config.
- Ruby 4.0.9 nie je v lokálnom rbenv (je tam 4.0.7) – doinštalovať, alebo overovať v Dockeri.

## Prístupy

- **A) Priamy skok na Rails 8.1 + Ruby 4.0.9, Sprockets ostávajú** – *zvolené.* Malá appka
  (29 Ruby súborov, ~640 riadkov testov), takže skok naraz je zvládnuteľný a frontend sa nemení.
- **B) Postupne cez každú minor verziu Rails** – bezpečnejšie, ale ~8 kôl práce bez veľkého
  zníženia rizika pri tejto veľkosti.
- **C) Kompletná modernizácia (Propshaft, importmap, dartsass-rails)** – zbytočne veľký zásah
  do frontendu, mimo rozsahu.

## Rozhodnuté

**Redis preč**
- `config.cache_store = :memory_store, { expires_in: 30.minutes }` v production aj staging
  (jediné použitie je `Rails.cache.fetch('dump_sizes')` v `HomepageController`).
- Vyhodiť `redis-rails`, ActionCable (`require "action_cable/engine"`, `config/cable.yml`,
  `app/channels/`, `app/assets/javascripts/cable.js`, `channels/.keep`).
- Odstrániť `redis` službu z `.github/workflows/slovensko_digital_ci.yml` a `REDIS_URL`
  z `Dockerfile`.

**Gemy** (moja voľba, overí sa buildom)
- `rails ~> 8.1.4`, `pg ~> 1.6`, aktuálna `puma`, `sprockets-rails`.
- Sass: `sass-rails` → `dartsass-sprockets`; ak sa pobije s `bootstrap-sass 3.4.1`
  (závisí na `sassc`), fallback na `sassc-rails`. Rozhoduje, či `assets:precompile` prejde
  a CSS ostane rovnaké.
- `uglifier` → `terser` (`config.assets.js_compressor = :terser`); `nodejs` v Dockerfile ostáva
  kvôli ExecJS.
- Vyhodiť `coffee-rails` (žiadne `.coffee` súbory), `rails_12factor`, `webdrivers`
  (Selenium Manager to rieši sám) a `Webdrivers::Chromedriver.update` zo `spec/support/capybara.rb`.
- Uvoľniť pin `simplecov`, aktualizovať testové gemy a monitoring (`newrelic_rpm`, `rollbar`).

**Konfigurácia**
- Pregenerovať config a `bin/*` cez `rails app:update`, ponechať vlastné nastavenia
  (locale `:sk`, `exceptions_app`, `schema_format :sql`, `default_url_options` z `APP_HOST`).
- `config/environments/staging.rb` ostáva ako kópia `production.rb`.
- Production/staging: statické súbory servíruje Puma a logy idú na STDOUT bez potreby nových ENV.
- Zmazať `config/secrets.yml` – prod/staging čítajú `SECRET_KEY_BASE` z ENV ako doteraz.
- `load_defaults 8.1` zmení odvodzovanie kľúčov cookies, takže existujúce session cookies
  (obsahujú len flash) sa raz zahodia. Akceptujem to bez rotátora; cookie `ref` je nepodpísaná,
  takže sa jej to netýka.
- `rspec`: `fixture_path` → `fixture_paths`.
- GitHub CI: `db:structure:load` → `db:schema:load` (structure:load v Rails 7+ neexistuje).
- `Dockerfile`: `FROM ruby:4.0.9`, bez `REDIS_URL` v precompile.
- `.gitlab/auto-deploy-values.yaml` a `Procfile` bez zmeny, pokiaľ to overenie nevyžiada.

## Ponechané na implementáciu

- Presné verzie gemov a poradie krokov.
- Opravy deprecations a chýb, ktoré ukážu testy, `zeitwerk:check` a boot na Ruby 4
  (napr. `rest-client 2.1.0` na Ruby 4 – ak nepôjde, nahradiť `Net::HTTP` v `GovboxController`).
- Ktoré staré initializery z Rails 5 zmazať (napr. `cookies_serializer.rb` – JSON je už default).

## Overenie

- `bundle exec rspec` zelené (vrátane feature testov s headless Chrome).
- `bin/rails zeitwerk:check` OK.
- `RAILS_ENV=production SECRET_KEY_BASE=x bin/rails assets:precompile` bez `REDIS_URL`.
- `docker build` + spustenie kontajnera s `DATABASE_URL` a `RAILS_ENV=production`, všetky cesty
  z `CHECKS` vrátia 200 a CSS/JS sa načítajú.
