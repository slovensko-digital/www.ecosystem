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
    }
  end
  let(:corporate_body) do
    {
      cin: '36421928',
      name: 'Firma, s. r. o.',
      tin: '2020123456',
      vatin: 'SK2020123456',
      formatted_street: 'Hlavná 1',
      postal_code: '811 01',
      municipality: 'Bratislava',
      country: 'Slovenská republika',
    }
  end
  let(:written_form) do
    form.merge(without_ico: '1', company_name: 'Ján Novák', street: 'Hlavná 1', postcode: '811 01', city: 'Bratislava', country: 'Česko')
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

  def stub_register(cin, results)
    stub_request(:get, "#{ENV.fetch('AUTOFORM_URL')}/api/corporate_bodies/search").
      with(query: hash_including(q: "cin:#{cin}", private_access_token: ENV.fetch('AUTOFORM_PRIVATE_ACCESS_TOKEN'))).
      to_return(status: 200, body: results.to_json)
  end

  it 'shows the new form with only the company instead of the Google Form' do
    get '/sluzby/autoform'

    registration_form = response.body[/<form[^>]*id="cap-registration-form".*?<\/form>/m]
    expect(registration_form).to include('name="company_name"', 'name="ico"', 'name="without_ico"')
    expect(registration_form).not_to include('name="dic"', 'Dajú sa aj prepísať')
    expect(response.body).not_to include('docs.google.com/forms/d/1TpYNJfBQVGt4lmKP')

    get '/sluzby/datahub'

    expect(response.body).to include('value="DATAHUB_API"', 'value="DATAHUB_SQL"')
    expect(response.body).not_to include('name="domain"')
  end

  it 'sends the registration with the billing data from the register and the secret' do
    stub_register('36421928', [corporate_body])
    stub = stub_registration(200, status: 'created', confirmation: 'SENT')

    post '/registracia', params: form

    expect(stub.with(
      headers: { 'x-registration-secret' => 'tajne' },
      body: hash_including('product' => 'AUTOFORM', 'email' => 'jan@firma.sk', 'companyName' => 'Firma, s. r. o.', 'ico' => '36421928', 'dic' => '2020123456', 'icDph' => 'SK2020123456', 'street' => 'Hlavná 1', 'postcode' => '811 01', 'city' => 'Bratislava', 'country' => 'Slovenská republika', 'source' => 'WEB_FORM')
    )).to have_been_requested
    expect(response).to redirect_to('/sluzby/autoform#registracia')

    follow_redirect!

    expect(response.body).to include('Ďakujeme, registráciu sme prijali. Ďalší postup vám pošleme e-mailom na jan@firma.sk.')

    get '/sluzby/autoform'

    expect(response.body).not_to include('registráciu sme prijali')
  end

  it 'answers every registration the same, so it does not tell who already is a client' do
    stub_register('36421928', [corporate_body])

    messages = [
      { status: 'created', confirmation: 'SENT' },
      { status: 'created', confirmation: 'MANUAL' },
      { status: 'resent' },
      { status: 'duplicate' },
      { status: 'updated' },
    ].map do |result|
      stub_registration(200, result)
      post '/registracia', params: form
      follow_redirect!
      response.body[/<div class="alert[^>]*>(.*?)<\/div>/m, 1]
    end

    expect(messages.uniq).to eq(['Ďakujeme, registráciu sme prijali. Ďalší postup vám pošleme e-mailom na jan@firma.sk.'])
  end

  it 'asks to check the IČO when the register does not know the company' do
    stub_register('36421999', [])

    post '/registracia', params: form.merge(ico: '36421999')
    follow_redirect!

    expect(a_request(:post, "#{cap}/s/registrations")).not_to have_been_made
    expect(response.body[/<div class="alert[^>]*>(.*?)<\/div>/m, 1]).to include('Firmu s týmto IČO sme v registri nenašli', 'Nemám slovenské IČO')
    expect(response.body).to include('value="36421999"', 'value="Firma s.r.o."')
  end

  describe 'without a Slovak IČO' do
    it 'hides the address until the client says so' do
      get '/sluzby/autoform'

      address = Nokogiri::HTML(response.body).at('#cap-registration-address')
      expect(address.css('[name]').map { |field| field['name'] }).to eq(%w[street postcode city country])
      expect(address.keys).to include('hidden')
      expect(address.css('input').map { |field| field['disabled'] }).to all(be_present)
    end

    it 'sends the billing data as written and does not look in the register' do
      stub_registration(200, status: 'created', confirmation: 'MANUAL')

      post '/registracia', params: written_form

      expect(a_request(:post, "#{cap}/s/registrations").with(
        body: hash_including('product' => 'AUTOFORM', 'email' => 'jan@firma.sk', 'companyName' => 'Ján Novák', 'street' => 'Hlavná 1', 'postcode' => '811 01', 'city' => 'Bratislava', 'country' => 'Česko', 'source' => 'WEB_FORM')
      ) { |request| !JSON.parse(request.body).key?('ico') }).to have_been_made
      expect(a_request(:get, "#{ENV.fetch('AUTOFORM_URL')}/api/corporate_bodies/search").with(query: hash_including({}))).not_to have_been_made

      follow_redirect!

      expect(response.body).to include('Ďakujeme, registráciu sme prijali. Ďalší postup vám pošleme e-mailom na jan@firma.sk.')
    end

    it 'keeps the address when CAP refuses it' do
      stub_registration(422, error: 'Chýbajú fakturačné údaje')

      post '/registracia', params: written_form
      follow_redirect!

      page = Nokogiri::HTML(response.body)
      expect(page.at('#cap_without_ico')['checked']).to be_present
      expect(page.at('#cap_ico')['disabled']).to be_present
      expect(page.at('#cap-registration-address').keys).not_to include('disabled', 'hidden')
      expect(page.at('#cap-registration-address [name="street"]')['value']).to eq('Hlavná 1')
      expect(page.at('label[for="cap_company_name"]').text).to eq('Meno a priezvisko alebo názov firmy')
    end
  end

  it 'keeps what the client wrote when CAP refuses it' do
    stub_register('36421928', [corporate_body])
    stub_registration(422, error: 'Neplatný e-mail')

    post '/registracia', params: form.merge(product: 'DATAHUB_SQL', email: 'jan.firma.sk')
    follow_redirect!

    expect(response.request.path).to eq('/sluzby/datahub')
    expect(response.body).to include('Registrácia sa nepodarila: Neplatný e-mail', 'value="jan.firma.sk"', 'value="36421928"', 'value="Firma s.r.o."')
    expect(response.body).to match(/value="DATAHUB_SQL" checked="checked"/)
  end

  it 'says when CAP is not available' do
    stub_register('36421928', [corporate_body])
    stub_request(:post, "#{cap}/s/registrations").to_timeout

    post '/registracia', params: form
    follow_redirect!

    expect(response.body).to include('Registráciu sa nepodarilo odoslať')
  end

  it 'says when the register is not available' do
    stub_request(:get, "#{ENV.fetch('AUTOFORM_URL')}/api/corporate_bodies/search").with(query: hash_including({})).to_timeout

    post '/registracia', params: form
    follow_redirect!

    expect(a_request(:post, "#{cap}/s/registrations")).not_to have_been_made
    expect(response.body).to include('Registráciu sa nepodarilo odoslať')
  end

  it 'sends nothing for a bot' do
    post '/registracia', params: form.merge(website: 'http://spam.example')

    expect(a_request(:get, "#{ENV.fetch('AUTOFORM_URL')}/api/corporate_bodies/search").with(query: hash_including({}))).not_to have_been_made
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
