Recaptcha.configure do |config|
  config.site_key = ENV.fetch('RECAPTCHA_SITE_KEY_V3')
  config.secret_key = ENV.fetch('RECAPTCHA_SECRET_KEY_V3')
end
