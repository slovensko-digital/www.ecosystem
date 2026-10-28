# Upgrade na Ruby 4.0 / Rails 8.1 a odstránenie Redisu – implementačný plán

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Aplikácia beží na Ruby 4.0.9 a Rails 8.1.4, bez Redisu, v jednom kontajneri bez viditeľnej zmeny na stránkach.

**Architecture:** Najprv zafixovať súčasné správanie (testy, screenshoty) a odstrániť Redis ešte na starom stacku. Potom jeden skok na Ruby 4 / Rails 8.1 s configom portovaným z čerstvej Rails 8.1 appky, potom výmena asset gemov (Sprockets ostávajú) a nakoniec overenie produkčného Docker image.

**Tech Stack:** Ruby 4.0.9, Rails 8.1.4, Sprockets (`sprockets-rails`, `dartsass-sprockets`, `terser`), Bootstrap 3 (`bootstrap-sass 3.4.1`), PostgreSQL (`structure.sql`), RSpec + Capybara + Selenium (headless Chrome), GitLab Auto DevOps.

**Spec:** `docs/superpowers/specs/2026-10-28-ruby4-rails8-upgrade-design.md`

## Global Constraints

- Ruby **4.0.9**, Rails **8.1.4**, `config.load_defaults 8.1`.
- Žiadny Redis: gem, config, `REDIS_URL`, CI služba – `grep -rni redis` mimo `docs/` nič nenájde.
- Žiadne nové tabuľky ani migrácie; `db/structure.sql` sa nemení.
- Žiadne nové povinné ENV premenné na staging/production (dnes: `SECRET_KEY_BASE`, `DATABASE_URL`, `PORT`, `RAILS_ENV` + kľúče z `.env`).
- Sprockets ostávajú; Bootstrap 3/4, jQuery (`jquery_ujs`), Turbolinks sa nemenia; žiadna viditeľná zmena na stránkach.
- Žiadny ActiveJob ani GoodJob.
- Jeden kontajner: `Procfile` len `web`, `.gitlab/auto-deploy-values.yaml` bez zmeny.
- `config/environments/staging.rb` je obsahovo zhodný s `production.rb`.
- Lokálne: Postgres beží (`datahub_development`, `datahub_test`), je `google-chrome`, `node`, `docker`, ImageMagick `compare`; Ruby 4.0.9 sa inštaluje cez `rbenv install 4.0.9`.

## Review Focus

- Prehliadač so starou Rails 5.2 session cookie po deployi → stránka vráti 200 a cookie sa potichu nahradí (spec v Task 0, beží aj po Task 2).
- Newsletter formulár odoslaný cez `jquery_ujs` (`remote: true`) → JS odpoveď 200 pri úspechu, 400 pri chybe (spec v Task 0).
- Produkčný kontajner bez `REDIS_URL`, `RAILS_SERVE_STATIC_FILES` a `RAILS_LOG_TO_STDOUT` → nabootuje, Puma servíruje `/assets/*`, logy idú na STDOUT (Task 4).
- Neexistujúca URL v produkcii → vlastná 404 stránka cez `exceptions_app` (Task 4).
- JS skomprimovaný `terser`-om (GovBox registrácia, Prism, anchor.js) → platný JS bez syntax chýb (Task 3).

---

### Task 0: Zafixovať súčasné správanie (starý stack)

**Files:**
- Create: `spec/requests/newsletter_subscriptions_spec.rb`
- Create: `spec/requests/stale_session_cookie_spec.rb`
- Artefakty (necommitujú sa): `tmp/upgrade-baseline/before/*.png`

**Interfaces:**
- Produces: dva request spec súbory, ktoré musia ostať zelené v Task 2–4; baseline screenshoty v `tmp/upgrade-baseline/before/` pre porovnanie v Task 3 a 4; počet testov v `tmp/upgrade-baseline/rspec.txt`.

- [ ] **Step 1: Napísať spec pre newsletter**

`RSpec.describe 'Newsletter subscription', type: :request`:
- `it 'responds with JS on success'` – `allow(NewsletterSubscriptionService).to receive(:subscribe).with('jan@example.com')`, `post newsletter_subscribe_path, params: { email: 'jan@example.com' }, xhr: true` → `expect(response).to have_http_status(:ok)`, `expect(response.media_type).to eq('text/javascript')`, `expect(response.body).to include('#newsletter-success')`.
- `it 'responds with JS error on failure'` – `allow(NewsletterSubscriptionService).to receive(:subscribe).and_raise(StandardError)` → `have_http_status(:bad_request)`, `media_type` `text/javascript`.

- [ ] **Step 2: Napísať spec pre starú session cookie**

`RSpec.describe 'Stale session cookie', type: :request`, `it 'ignores an undecryptable session cookie'`: `cookies['_ecosystem_session'] = 'garbage--abc'`, `get '/podmienky'` → `have_http_status(:ok)` a `response.body` obsahuje `Podmienky používania datasetov`.

- [ ] **Step 3: Spustiť celú suite na starom stacku**

Run: `bundle exec rspec | tee tmp/upgrade-baseline/rspec.txt`
Expected: `0 failures` (nové specy prechádzajú, charakterizujú súčasné správanie).

- [ ] **Step 4: Nasnímať baseline screenshoty**

Spustiť `bin/rails s -p 3000` (development, DB `datahub_development`) na pozadí, potom:

```bash
mkdir -p tmp/upgrade-baseline/before
for p in "" sluzby/govbox sluzby/autoform sluzby/datahub otvorene-data otvorene-api premiove-data premiove-api podmienky 404; do
  name=${p//\//_}; name=${name:-home}
  google-chrome --headless=new --disable-gpu --hide-scrollbars --window-size=1280,3000 \
    --screenshot="tmp/upgrade-baseline/before/$name.png" "http://localhost:3000/$p"
done
```

Expected: 10 PNG súborov, každý zobrazuje naštýlovanú stránku (skontrolovať pohľadom aspoň `home.png` a `sluzby_govbox.png`). Server zastaviť.

- [ ] **Step 5: Commit**

```bash
git add spec/requests
git commit -m "Pin newsletter XHR and stale session cookie behaviour before upgrade"
```

---

### Task 1: Odstrániť Redis a ActionCable (starý stack)

**Files:**
- Modify: `config/environments/production.rb:60`, `config/environments/staging.rb:60`
- Modify: `config/application.rb:12` (`require "action_cable/engine"` zakomentovať ako ostatné nepoužité railties)
- Modify: `Gemfile`, `Gemfile.lock` (vyhodiť `redis-rails`)
- Modify: `.github/workflows/slovensko_digital_ci.yml` (vyhodiť službu `redis`)
- Modify: `Dockerfile` (vyhodiť `REDIS_URL=...` z riadku s `assets:precompile`)
- Delete: `config/cable.yml`, `app/channels/`, `app/assets/javascripts/cable.js`, `app/assets/javascripts/channels/`

**Interfaces:**
- Consumes: zelená suite z Task 0.
- Produces: `Rails.cache` v production/staging je `ActiveSupport::Cache::MemoryStore` s `expires_in: 30.minutes`; app neobsahuje ActionCable.

- [ ] **Step 1: Overiť, že produkcia bez Redisu dnes nenabootuje**

Run: `RAILS_ENV=production SECRET_KEY_BASE=x DATABASE_URL=postgres:///datahub_development bin/rails runner 'puts Rails.cache.class'`
Expected: FAIL s `KeyError: key not found: "REDIS_URL"`.

- [ ] **Step 2: Prepnúť cache a vyhodiť Redis/ActionCable**

V oboch env súboroch `config.cache_store = :memory_store, { expires_in: 30.minutes }`. Zmazať súbory zo zoznamu vyššie, `redis-rails` z Gemfile, `bundle install`, Redis z CI a Dockerfile.

- [ ] **Step 3: Overiť boot bez Redisu**

Run: príkaz zo Step 1, aj s `RAILS_ENV=staging`.
Expected: oba vypíšu `ActiveSupport::Cache::MemoryStore`.

- [ ] **Step 4: Overiť testy, precompile a čistotu**

Run: `bundle exec rspec` → `0 failures`, rovnaký počet príkladov ako v `tmp/upgrade-baseline/rspec.txt`.
Run: `RAILS_ENV=production SECRET_KEY_BASE=x bin/rails assets:precompile && bin/rails assets:clobber` → prejde bez `REDIS_URL`.
Run: `grep -rni redis --exclude-dir={.git,docs,tmp,log} .` → nič.

- [ ] **Step 5: Commit**

```bash
git add -A
git commit -m "Remove Redis: use in-process memory cache store, drop ActionCable"
```

---

### Task 2: Ruby 4.0.9 + Rails 8.1.4

**Files:**
- Modify: `.ruby-version` (`4.0.9`), `Gemfile` (`ruby '4.0.9'`), `Gemfile.lock`
- Modify: `config/application.rb`, `config/boot.rb`, `config/environment.rb`, `config.ru`, `config/puma.rb`, `config/environments/{development,test,production,staging}.rb`
- Modify: `config/initializers/{filter_parameter_logging,assets,session_store,rollbar,brevo,inflections}.rb` (ponechať, zosúladiť so šablónou)
- Delete: `config/initializers/{application_controller_renderer,backtrace_silencers,cookies_serializer,mime_types,wrap_parameters,content_security_policy}.rb`, `config/secrets.yml`, `config/storage.yml`, `app/jobs/application_job.rb`, `bin/bundle`, `bin/update`, `bin/yarn`
- Modify: `bin/rails`, `bin/rake`, `bin/setup` (z Rails 8.1 šablóny)
- Modify: `spec/rails_helper.rb`, `spec/support/capybara.rb`
- Modify: `.github/workflows/slovensko_digital_ci.yml`

**Interfaces:**
- Consumes: app bez Redisu z Task 1; specy z Task 0.
- Produces: app na Rails 8.1.4 / Ruby 4.0.9; asset gemy (`sass-rails`, `uglifier`, `coffee-rails`) sú zatiaľ pôvodné – mení ich Task 3; `production.rb` už nepotrebuje `rails_12factor`.

- [ ] **Step 1: Pripraviť Ruby a referenčnú appku**

`rbenv install 4.0.9`, potom `gem install rails -v 8.1.4` a vygenerovať referenčnú appku mimo repa: `rails _8.1.4_ new <scratchpad>/ecosystem_ref --database=postgresql --skip-bundle --skip-git` plus `--skip-*` pre všetko, čo app nepoužíva (Action Cable, Active Storage, Action Mailbox, Action Text, Active Job, JavaScript, Hotwire, Test, Kamal, Thruster, Solid, Docker, CI, RuboCop, Brakeman, Bootsnap). Ak 8.1 niektorý flag nepozná (`rails new --help`), vynechať ho. Appka slúži len ako predloha configu.

- [ ] **Step 2: Gemfile**

- `rails '~> 8.1.4'`, `pg '~> 1.6'`, `puma` bez pinu; pridať `sprockets-rails` (Rails 8 ho už neťahá).
- Vyhodiť: `rails_12factor` (celá skupina `:staging, :production`), `webdrivers`, `spring-watcher-listen`.
- `simplecov` bez pinu, `rspec-rails '~> 8.0'`, ostatné testové a monitoring gemy bez pinu na najnovšie.
- `pry-byebug` ponechať; ak sa na Ruby 4 nenainštaluje, nahradiť gemom `debug`.
- `sass-rails`, `coffee-rails`, `uglifier`, `bootstrap-sass 3.4.1`, `jquery-rails`, `turbolinks`, `rest-client`, `brevo ~> 4.0`, `dotenv-rails` ponechať.

Run: `bundle update --all` → prejde, `Gemfile.lock` obsahuje `rails (8.1.4)` a `ruby 4.0.9`.

- [ ] **Step 3: Config z referenčnej appky**

Porovnať a preniesť súbory z referenčnej appky, s týmito rozhodnutiami:
- `config/application.rb`: rovnaké railties ako dnes bez `action_cable` a `active_job`; `config.load_defaults 8.1`; `config.autoload_lib(ignore: %w[assets tasks])`; ponechať `i18n.load_path`, `default_locale = :sk`, `schema_format = :sql`, `exceptions_app = self.routes`.
- `production.rb` (a identický `staging.rb`): šablóna 8.1 + `cache_store` z Task 1, `config.assets.compile = false`, `config.assets.js_compressor = :uglifier`, `config.public_file_server.enabled = true` (nikto pred Pumou nie je), logger na STDOUT bez podmienky (ako v šablóne), `config.log_level = :debug` (ako dnes), `config.i18n.fallbacks = true`, `dump_schema_after_migration = false`; na konci ponechať `Rails.application.routes.default_url_options[:host] = ENV['APP_HOST']`. Žiadne `force_ssl`/`assume_ssl` (dnes vypnuté).
- `test.rb`: šablóna 8.1, ale `config.action_dispatch.show_exceptions = :none` (ekvivalent dnešného `false`).
- `development.rb`: šablóna 8.1, cache prepínaná cez `tmp/caching-dev.txt` ako dnes.
- `session_store.rb` ponechať (kľúč `_ecosystem_session`), `assets.rb` bez riadku s `node_modules`, `filter_parameter_logging.rb` zo šablóny.
- `spec/rails_helper.rb`: `config.fixture_paths = [Rails.root.join('spec/fixtures')]`, `config.file_fixture_path = Rails.root.join('spec/fixtures')`.
- `spec/support/capybara.rb`: bez `Webdrivers::Chromedriver.update`; `Selenium::WebDriver::Chrome::Options.new(args: %w[headless=new disable-gpu disable-logging])`.
- CI: `bundle exec rails db:create db:schema:load --trace` (namiesto `db:structure:load`).

- [ ] **Step 4: Overiť autoloading a boot**

Run: `bin/rails zeitwerk:check` → `All is good!`
Run: `RAILS_ENV=production SECRET_KEY_BASE=x DATABASE_URL=postgres:///datahub_development bin/rails runner 'puts Rails.version, RUBY_VERSION, Rails.cache.class'` (aj s `RAILS_ENV=staging`)
Expected: `8.1.4`, `4.0.9`, `ActiveSupport::Cache::MemoryStore`.
Ak boot spadne na `rest-client` (chýbajúca knižnica na Ruby 4), nahradiť dve volania v `app/controllers/services/govbox_controller.rb` cez `Net::HTTP` so zachovaním timeoutu 10 s a ošetrenia chybových odpovedí, a vyhodiť gem.

- [ ] **Step 5: Spustiť suite**

Run: `bundle exec rspec`
Expected: `0 failures`, rovnaký počet príkladov ako baseline (vrátane GovBox registrácie s `js: true` a oboch specov z Task 0). Deprecation warningy z Rails opraviť; z gemov tretích strán ignorovať.

- [ ] **Step 6: Commit**

```bash
git add -A
git commit -m "Upgrade to Ruby 4.0.9 and Rails 8.1.4"
```

---

### Task 3: Asset gemy (Sprockets ostávajú)

**Files:**
- Modify: `Gemfile`, `Gemfile.lock`
- Modify: `config/environments/production.rb`, `config/environments/staging.rb` (`js_compressor`)
- Artefakty: `tmp/upgrade-baseline/after-dev/*.png`

**Interfaces:**
- Consumes: Rails 8.1 app z Task 2, baseline screenshoty z Task 0.
- Produces: `config.assets.js_compressor = :terser`; Sass kompiluje `dartsass-sprockets` (alebo fallback `sassc-rails`).

- [ ] **Step 1: Vymeniť gemy**

`sass-rails` → `dartsass-sprockets`, `uglifier` → `terser`, vyhodiť `coffee-rails`. V oboch env súboroch `config.assets.js_compressor = :terser`. `bundle install`.

- [ ] **Step 2: Precompile a platnosť JS**

Run: `RAILS_ENV=production SECRET_KEY_BASE=x bin/rails assets:precompile`
Expected: prejde; vzniknú `public/assets/application-*.{css,js}` a `application_bs4-*.{css,js}`.
Run: `for f in public/assets/application*.js; do node --check "$f" || echo "BROKEN $f"; done` → nič `BROKEN`.
Fallback: ak Bootstrap 3 nekompiluje cez dart-sass (chyba importu/syntaxe, nie len deprecation warningy), vrátiť `sassc-rails` namiesto `dartsass-sprockets` a zopakovať step.
Potom `bin/rails assets:clobber`.

- [ ] **Step 3: Porovnať screenshoty**

Spustiť `bin/rails s -p 3000` (development), nasnímať rovnakým cyklom ako v Task 0 Step 4 do `tmp/upgrade-baseline/after-dev/`, potom pre každý súbor `compare -metric AE -fuzz 2% before/X.png after-dev/X.png diff-X.png`.
Expected: `0` (alebo blízko 0) pre každú stránku. Každú nenulovú stránku pozrieť pohľadom; rozdiel v zobrazených veľkostiach dumpov na `home` je očakávaný (živé dáta z S3), čokoľvek iné viditeľné je chyba.

- [ ] **Step 4: Testy a commit**

Run: `bundle exec rspec` → `0 failures`.

```bash
git add -A
git commit -m "Switch Sass to dart-sass and JS compressor to terser, drop coffee-rails"
```

---

### Task 4: Produkčný Docker image

**Files:**
- Modify: `Dockerfile`
- Artefakty: `tmp/upgrade-baseline/after-prod/*.png`

**Interfaces:**
- Consumes: celá app z Task 3.
- Produces: image, ktorý GitLab Auto DevOps zbuilduje a pustí s existujúcimi ENV.

- [ ] **Step 1: Upraviť Dockerfile**

`FROM ruby:4.0.9`; `nodejs` ostáva (ExecJS pre `terser` a `autoprefixer-rails`); `bundle config set --local deployment true` a `bundle config set --local without 'development test'`; precompile `SECRET_KEY_BASE_DUMMY=1 RAILS_ENV=production bundle exec rails assets:precompile`; `CMD` bez zmeny.

- [ ] **Step 2: Build**

Run: `docker build -t ecosystem-upgrade .`
Expected: build prejde.

- [ ] **Step 3: Spustiť kontajner ako v GitLabe**

`docker run -d --name eco --network host -e RAILS_ENV=production -e PORT=5000 -e SECRET_KEY_BASE=$(openssl rand -hex 64) -e DATABASE_URL=<TCP URL na datahub_development>` + každý kľúč z `.env` s dummy neprázdnou hodnotou. Bez `REDIS_URL`, `RAILS_SERVE_STATIC_FILES`, `RAILS_LOG_TO_STDOUT`.

- [ ] **Step 4: Overiť kontajner**

- Každá cesta z `CHECKS`: `curl -s -o /dev/null -w '%{http_code}' localhost:5000<cesta>` → `200`; `/health/all_env_set` a `/health/services` vrátia `ok`.
- CSS/JS z HTML homepage (`curl -s localhost:5000/ | grep -o '/assets/[^"]*'`) → každý `200`, CSS má `Content-Type: text/css`.
- `curl -s -w '%{http_code}' localhost:5000/neexistujuca-stranka` → `404` a telo obsahuje `Stránka sa nenašla`.
- `docker logs eco` obsahuje riadky `Started GET`.
- `docker stats --no-stream eco` po prejdení stránok → pamäť pod `400MiB`.
- Screenshoty cyklom z Task 0 Step 4 proti `http://localhost:5000/` do `tmp/upgrade-baseline/after-prod/` a `compare` proti `before/` ako v Task 3 Step 3 → rovnaké kritérium.

Potom `docker rm -f eco`.

- [ ] **Step 5: Commit**

```bash
git add Dockerfile
git commit -m "Build production image on Ruby 4.0.9"
```
