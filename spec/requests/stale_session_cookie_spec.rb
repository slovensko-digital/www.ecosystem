require 'rails_helper'

RSpec.describe 'Stale session cookie', type: :request do
  it 'ignores an undecryptable session cookie' do
    cookies['_ecosystem_session'] = 'garbage--abc'

    get '/podmienky'

    expect(response).to have_http_status(:ok)
    expect(response.body).to include('Podmienky používania datasetov')
  end

  it 'ignores a genuine Rails 5.2 format (AES-256-CBC + SHA1) session cookie' do
    cookies['_ecosystem_session'] = legacy_session_cookie

    get '/podmienky'

    expect(response).to have_http_status(:ok)
    expect(response.body).to include('Podmienky používania datasetov')
  end

  # Builds the cookie the app issued under `load_defaults 5.1`: JSON payload,
  # SHA1-derived keys, aes-256-cbc cipher and SHA1 HMAC.
  def legacy_session_cookie
    passthrough = Object.new
    def passthrough.dump(value) = value
    def passthrough.load(value) = value

    key_generator = ActiveSupport::KeyGenerator.new(
      Rails.application.secret_key_base, iterations: 1000, hash_digest_class: OpenSSL::Digest::SHA1
    )
    encryptor = ActiveSupport::MessageEncryptor.new(
      key_generator.generate_key('encrypted cookie', 32),
      key_generator.generate_key('signed encrypted cookie'),
      cipher: 'aes-256-cbc', digest: 'SHA1', serializer: passthrough
    )
    payload = { 'session_id' => 'a' * 32, '_csrf_token' => 't' * 44,
                'flash' => { 'discard' => [], 'flashes' => { 'notice' => 'hi' } } }

    ERB::Util.url_encode(encryptor.encrypt_and_sign(JSON.dump(payload)))
  end
end
