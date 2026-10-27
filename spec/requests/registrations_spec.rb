require 'rails_helper'

RSpec.describe 'Registrations through CAP', type: :request do
  let(:cap) { 'https://cap.test' }
  let(:form) do
    {
      product: 'AUTOFORM',
      email: 'jan@firma.sk',
      domain: '',
      company_name: 'Firma s.r.o.',
      ico: '36421928',
      dic: '2020123456',
      ic_dph: '',
      street: 'Hlavná 1',
      postcode: '811 01',
      city: 'Bratislava',
      country: 'Slovenská republika',
    }
  end

  around do |example|
    ENV['CAP_URL'] = cap
    ENV['CAP_REGISTRATION_SECRET'] = 'tajne'
    example.run
  ensure
    ENV.delete('CAP_URL')
    ENV.delete('CAP_REGISTRATION_SECRET')
  end

  def stub_registration(status, body)
    stub_request(:post, "#{cap}/s/registrations").to_return(status: status, body: body.to_json, headers: { 'Content-Type' => 'application/json' })
  end

  it 'shows the new form instead of the Google Form' do
    get '/sluzby/autoform'

    expect(response.body).to include('id="cap-registration-form"', 'name="company_name"', 'data-slovensko-digital-autoform="formatted-street"')
    expect(response.body).not_to include('docs.google.com/forms/d/1TpYNJfBQVGt4lmKP')

    get '/sluzby/datahub'

    expect(response.body).to include('value="DATAHUB_API"', 'value="DATAHUB_SQL"')
    expect(response.body).not_to include('name="domain"')
  end

  it 'sends the registration with the secret and says the e-mail is on its way' do
    stub = stub_registration(200, status: 'created', confirmation: 'SENT')

    post '/registracia', params: form

    expect(stub.with(
      headers: { 'x-registration-secret' => 'tajne' },
      body: hash_including('product' => 'AUTOFORM', 'email' => 'jan@firma.sk', 'companyName' => 'Firma s.r.o.', 'ico' => '36421928', 'street' => 'Hlavná 1', 'postcode' => '811 01', 'city' => 'Bratislava', 'source' => 'WEB_FORM')
    )).to have_been_requested
    expect(response).to redirect_to('/sluzby/autoform#registracia')

    follow_redirect!

    expect(response.body).to include('Na jan@firma.sk sme poslali e-mail s vašimi údajmi a odkazom')

    get '/sluzby/autoform'

    expect(response.body).not_to include('sme poslali e-mail')
  end

  it 'keeps what the client wrote when CAP refuses it' do
    stub_registration(422, error: 'Neplatné IČO')

    post '/registracia', params: form.merge(product: 'DATAHUB_SQL', ico: 'SK1')
    follow_redirect!

    expect(response.request.path).to eq('/sluzby/datahub')
    expect(response.body).to include('Registrácia sa nepodarila: Neplatné IČO', 'value="SK1"', 'value="Firma s.r.o."')
    expect(response.body).to match(/value="DATAHUB_SQL" checked="checked"/)
  end

  it 'says when CAP is not available' do
    stub_request(:post, "#{cap}/s/registrations").to_timeout

    post '/registracia', params: form
    follow_redirect!

    expect(response.body).to include('Registráciu sa nepodarilo odoslať')
  end

  it 'sends nothing for a bot' do
    post '/registracia', params: form.merge(website: 'http://spam.example')

    expect(a_request(:post, "#{cap}/s/registrations")).not_to have_been_made
  end

  describe 'the page of the link' do
    it 'only shows the button when opened' do
      get '/registracia/potvrdenie', params: { t: 'token-0123456789abcdefghij' }

      expect(response.body).to include('Potvrdzujem registráciu a súhlasím s VOP', 'value="token-0123456789abcdefghij"')
      expect(a_request(:post, "#{cap}/s/registrations/confirm")).not_to have_been_made
    end

    it 'confirms the registration by the button' do
      stub = stub_request(:post, "#{cap}/s/registrations/confirm")
        .with(headers: { 'x-registration-secret' => 'tajne' }, body: { token: 'token-0123456789abcdefghij' }.to_json)
        .to_return(status: 200, body: { status: 'activating', email: 'jan@firma.sk' }.to_json)

      post '/registracia/potvrdenie', params: { t: 'token-0123456789abcdefghij' }

      expect(stub).to have_been_requested
      expect(response.body).to include('Registrácia je potvrdená. Prístupové údaje vám o pár minút pošleme na jan@firma.sk.')
    end

    it 'still understands an activation CAP did at once' do
      stub_request(:post, "#{cap}/s/registrations/confirm")
        .to_return(status: 200, body: { status: 'activated', email: 'jan@firma.sk' }.to_json)

      post '/registracia/potvrdenie', params: { t: 'token-0123456789abcdefghij' }

      expect(response.body).to include('Registrácia je potvrdená. Prístupové údaje sme poslali na jan@firma.sk.')
    end

    it 'tells an old link' do
      stub_request(:post, "#{cap}/s/registrations/confirm").to_return(status: 200, body: { status: 'invalid' }.to_json)

      post '/registracia/potvrdenie', params: { t: 'old-token-0123456789abcdef' }

      expect(response.body).to include('Odkaz neplatí alebo vypršal')
    end
  end

  it 'tells a staging from the real web' do
    get '/sluzby/autoform'
    expect(response.body).not_to include('staging-notice')

    ENV['STAGING_NOTICE'] = 'Registrácie idú do testovacieho systému.'
    get '/sluzby/autoform'
    expect(response.body).to include('Toto je testovacie prostredie webu Ekosystému, nie ostrá verzia.', 'Registrácie idú do testovacieho systému.')
  ensure
    ENV.delete('STAGING_NOTICE')
  end

  it 'keeps the Google Form without CAP' do
    ENV.delete('CAP_URL')

    get '/sluzby/autoform'

    expect(response.body).to include('docs.google.com/forms/d/1TpYNJfBQVGt4lmKP')
    expect(response.body).not_to include('cap-registration-form')
  end
end
