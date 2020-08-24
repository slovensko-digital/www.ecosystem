source 'https://rubygems.org'

ruby '2.6.6'

gem 'rails', '~> 5.2.4.3'
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

# Api
gem 'redis-rails'

# Utilities
gem 'rest-client'

group :development, :test do
  gem 'dotenv-rails'
  gem 'pry-byebug'
  gem 'rack-mini-profiler'
  gem 'rspec-rails'
end

group :development do
  gem 'listen'
  gem 'spring'
  gem 'spring-watcher-listen'
  gem 'web-console'
end

group :staging, :production do
  gem 'rails_12factor'
end

group :test do
  gem 'capybara'
  gem 'launchy'
  # Workaround for cc-test-reporter with SimpleCov 0.18.
  # Stop upgrading SimpleCov until the following issue will be resolved.
  # https://github.com/codeclimate/test-reporter/issues/418
  gem 'simplecov', '~> 0.10', '< 0.18'
  gem 'webmock'
end
