source 'https://rubygems.org'

ruby '4.0.10'

gem 'rails', '~> 8.1.4'
gem 'pg', '~> 1.6'
gem 'puma'
gem 'sprockets-rails'

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', require: false

# Add HTTP asset caching/compression and X-Sendfile acceleration to Puma [https://github.com/basecamp/thruster/]
gem 'thruster', require: false

# Styles
gem 'bootstrap-sass', '3.4.1'
gem 'dartsass-sprockets'

# Scripts
gem 'jquery-rails'
gem 'turbolinks'
gem 'terser'

# Monitoring
gem 'rollbar'

# Utilities
gem 'ostruct' # OpenStruct is a bundled gem since Ruby 4.0
gem 'rest-client'

group :development, :test do
  gem 'dotenv-rails'
  gem 'pry-byebug'
  gem 'pry-rails'
  gem 'rack-mini-profiler'
  gem 'rspec-rails', '~> 8.0'
end

group :development do
  gem 'web-console'
end

group :test do
  gem 'selenium-webdriver'
  gem 'capybara'
  gem 'launchy'
  gem 'simplecov'
  gem 'webmock'
end

gem "brevo", "~> 4.0"
