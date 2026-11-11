require 'rails_helper'

RSpec.feature 'Registration through CAP', type: :feature do
  around do |example|
    ENV['CAP_URL'] = 'https://cap.test'
    ENV['CAP_REGISTRATION_SECRET'] = 'tajne'
    example.run
  ensure
    ENV.delete('CAP_URL')
    ENV.delete('CAP_REGISTRATION_SECRET')
  end

  scenario 'a client without a Slovak IČO writes the address instead', js: true do
    stub = stub_request(:post, 'https://cap.test/s/registrations')
      .to_return(status: 200, body: { status: 'created', confirmation: 'MANUAL' }.to_json, headers: { 'Content-Type' => 'application/json' })

    visit '/sluzby/datahub'

    expect(page).to have_no_field('cap_street')

    check 'cap_without_ico'

    expect(page).to have_no_field('cap_ico')
    expect(page).to have_css('label[for="cap_company_name"]', text: 'Meno a priezvisko alebo názov firmy')

    fill_in 'cap_email', with: 'jan@novak.sk'
    fill_in 'cap_company_name', with: 'Ján Novák'
    fill_in 'cap_street', with: 'Hlavná 1'
    fill_in 'cap_postcode', with: '811 01'
    fill_in 'cap_city', with: 'Bratislava'
    click_on 'Zaregistrovať'

    expect(page).to have_content('Ďakujeme, registráciu sme prijali.')
    expect(stub.with(body: hash_including('product' => 'DATAHUB_API', 'companyName' => 'Ján Novák', 'street' => 'Hlavná 1', 'postcode' => '811 01', 'city' => 'Bratislava'))).to have_been_requested
  end
end
