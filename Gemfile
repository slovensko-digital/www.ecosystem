source 'https://rubygems.org'

ruby '2.6.6'

gem 'rails', '~> 5.2.4.4'
gem 'pg', '~> 0.18'
gem 'puma'

# Styles
gem 'bootstrap-sass', '3.4.1'
gem 'sass-rails'

# Scripts
gem 'coffee-rails'
gem 'jquery-rails'
gem 'turbolinks'
gem 'uglifier'

# Monitoring
gem 'newrelic_rpm'
gem 'rollbar'

# Utilities
gem 'redis-rails'
gem 'rest-client'
gem 'recaptcha'

group :development, :test do
  gem 'dotenv-rails'
  gem 'pry-byebug'
  gem 'pry-rails'
  gem 'rack-mini-profiler'
  gem 'rspec-rails'
end

group :development do
  gem 'spring-watcher-listen'
  gem 'web-console'
end

group :staging, :production do
  gem 'rails_12factor'
end

group :test do
  gem 'selenium-webdriver'
  gem 'webdrivers'
  gem 'capybara'
  gem 'launchy'
  gem 'simplecov', '~> 0.10', '< 0.18'
  gem 'webmock'
end
