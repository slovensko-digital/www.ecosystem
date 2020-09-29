require 'rails_helper'

RSpec.feature 'Govbox registration', type: :feature do
  background do
    stub_request(:get, "#{ENV.fetch('AUTOFORM_URL')}/api/corporate_bodies/search").
      with(query: hash_including(q: "cin:50 158 635", private_access_token: ENV.fetch('AUTOFORM_PRIVATE_ACCESS_TOKEN')))
      .to_return(status: 200, body: file_fixture('autoform_api_response.json').read)
  end

  scenario 'User registers for govbox' do
    visit '/sluzby/govbox'
    within('#registration') do
      click_on 'Mám záujem o GovBox'
    end

    expect(current_path).to have_content 'registracia'

    expect(page.find('#mode__sync_mode')).not_to be_checked
    expect(page.find('#mode__api_mode')).not_to be_checked
    choose('Mám záujem o GovBox na preposielanie správ zo schránky na email.')
    click_on 'Ďalej'

    expect(current_path).to have_content 'registracia-subjekt'

    fill_in 'Názov', with: 'Slovensko.Digital'
    fill_in 'IČO', with: '50 158 635'
    click_on 'Ďalej'

    expect(current_path).to have_content 'registracia-statutar'

    fill_in 'Meno', with: 'Ján'
    fill_in 'Priezvisko', with: 'Hargaš'
    fill_in 'Trvalé bydlisko', with: 'Koprivnická 9/B, 841 04 Bratislava'
    click_on 'Ďalej'

    expect(current_path).to have_content 'egistracia-nastavenie'

    fill_in 'Email', with: 'jan.hargas@slovensko.digital'
    fill_in 'Mobilný telefón', with: '+421903919123'
    click_on 'Ďalej'

    expect(current_path).to have_content 'registracia-zabezpecenie'

    fill_in 'Zvoľte si heslo', with: 'nejakeheslo'
    fill_in 'Heslo (znova)', with: 'nejakeheslo'

    stub_request(:post, ENV.fetch('GOVBOX_FORM_ENDPOINT')).
      with(body: { 'cin' => '50 158 635', 'email' => 'jan.hargas@slovensko.digital', 'family_name' => 'Hargaš',
        'given_name' => 'Ján', 'legal_subject_name' => 'Slovensko.Digital', 'mode' => 'sync_mode',
        'password' => 'nejakeheslo', 'password_confirmation' => 'nejakeheslo',
        'person_formatted_address' => 'Koprivnická 9/B, 841 04 Bratislava', 'phone' => '+421903919123',
        'referral_code' => '',
      }).to_return(status: 201)
    click_on 'Dokončiť registráciu'

    expect(current_path).to have_content 'registracia-uspesna'

    expect(page).to have_content('Registrácia úspešná!')
  end

  scenario 'Selecting between GovBox and GovBox API is required' do
    visit '/sluzby/govbox/registracia'

    expect(page.find('#mode__sync_mode')[:required]).to be_present
    expect(page.find('#mode__sync_mode')[:required]).to be_present
  end

  scenario 'User registers for GovBox API' do
    visit '/sluzby/govbox'
    within('#registration') do
      click_on 'Mám záujem o GovBox'
    end

    expect(page.find('#mode__sync_mode')).not_to be_checked
    expect(page.find('#mode__api_mode')).not_to be_checked
    choose('Mám záujem o GovBox API na integráciu vlastného informačného systému.')
    click_on 'Ďalej'

    fill_in 'Názov', with: 'Slovensko.Digital'
    fill_in 'IČO', with: '50 158 635'

    click_on 'Ďalej'

    fill_in 'Meno', with: 'Ján'
    fill_in 'Priezvisko', with: 'Hargaš'
    fill_in 'Trvalé bydlisko', with: 'Koprivnická 9/B, 841 04 Bratislava'
    click_on 'Ďalej'

    fill_in 'Email', with: 'jan.hargas@slovensko.digital'
    fill_in 'Mobilný telefón', with: '+421903919123'
    click_on 'Ďalej'

    fill_in 'Zvoľte si heslo', with: 'nejakeheslo'
    fill_in 'Heslo (znova)', with: 'nejakeheslo'

    stub_request(:post, ENV.fetch('GOVBOX_FORM_ENDPOINT')).
      with(body: { 'cin' => '50 158 635', 'email' => 'jan.hargas@slovensko.digital', 'family_name' => 'Hargaš',
        'given_name' => 'Ján', 'legal_subject_name' => 'Slovensko.Digital', 'mode' => 'api_mode',
        'password' => 'nejakeheslo', 'password_confirmation' => 'nejakeheslo',
        'person_formatted_address' => 'Koprivnická 9/B, 841 04 Bratislava', 'phone' => '+421903919123',
        'referral_code' => '',
      }).to_return(status: 201)
    click_on 'Dokončiť registráciu'

    expect(page).to have_content('Registrácia úspešná!')
  end

  scenario 'User cannot finish registration for GovBox' do
    visit '/sluzby/govbox'
    within('#header') do
      click_on 'Mám záujem o GovBox'
    end

    expect(page.find('#mode__sync_mode')).not_to be_checked
    expect(page.find('#mode__api_mode')).not_to be_checked
    choose('Mám záujem o GovBox na preposielanie správ zo schránky na email.')
    click_on 'Ďalej'

    fill_in 'Názov', with: 'Slovensko.Digital'
    fill_in 'IČO', with: '50 158 635'
    click_on 'Ďalej'

    fill_in 'Meno', with: 'Ján'
    fill_in 'Priezvisko', with: 'Hargaš'
    fill_in 'Trvalé bydlisko', with: 'Koprivnická 9/B, 841 04 Bratislava'
    click_on 'Ďalej'

    fill_in 'Email', with: 'jan.hargas@slovensko.digital'
    fill_in 'Mobilný telefón', with: '+421903919123'
    click_on 'Ďalej'

    fill_in 'Zvoľte si heslo', with: 'nejakeheslo'
    fill_in 'Heslo (znova)', with: 'nejakeheslo'

    stub_request(:post, ENV.fetch('GOVBOX_FORM_ENDPOINT')).to_return(status: [500, 'Internal Server Error'])

    click_on 'Dokončiť registráciu'

    expect(page).to have_content('momentálne nie je možné dokončiť registráciu')

    stub_request(:post, ENV.fetch('GOVBOX_FORM_ENDPOINT')).
      with(body: { 'cin' => '50 158 635', 'email' => 'jan.hargas@slovensko.digital', 'family_name' => 'Hargaš',
        'given_name' => 'Ján', 'legal_subject_name' => 'Slovensko.Digital', 'mode' => 'sync_mode',
        'password' => 'nejakeheslo', 'password_confirmation' => 'nejakeheslo',
        'person_formatted_address' => 'Koprivnická 9/B, 841 04 Bratislava', 'phone' => '+421903919123',
        'referral_code' => ''
      }).to_return(status: 201)

    click_on 'Skúsiť dokončiť registráciu znova'

    expect(page).to have_content('Registrácia úspešná!')
  end

  scenario 'We track referral code' do
    visit '/sluzby/govbox?ref=sf'
    within('#registration') do
      click_on 'Mám záujem o GovBox'
    end

    expect(page.find('#mode__sync_mode')).not_to be_checked
    expect(page.find('#mode__api_mode')).not_to be_checked
    choose('Mám záujem o GovBox API na integráciu vlastného informačného systému.')
    click_on 'Ďalej'

    fill_in 'Názov', with: 'Slovensko.Digital'
    fill_in 'IČO', with: '50 158 635'
    click_on 'Ďalej'

    fill_in 'Meno', with: 'Ján'
    fill_in 'Priezvisko', with: 'Hargaš'
    fill_in 'Trvalé bydlisko', with: 'Koprivnická 9/B, 841 04 Bratislava'
    click_on 'Ďalej'

    fill_in 'Email', with: 'jan.hargas@slovensko.digital'
    fill_in 'Mobilný telefón', with: '+421903919123'
    click_on 'Ďalej'

    fill_in 'Zvoľte si heslo', with: 'nejakeheslo'
    fill_in 'Heslo (znova)', with: 'nejakeheslo'

    stub_request(:post, ENV.fetch('GOVBOX_FORM_ENDPOINT')).to_return(status: [500, 'Internal Server Error'])

    click_on 'Dokončiť registráciu'

    stub_request(:post, ENV.fetch('GOVBOX_FORM_ENDPOINT')).
      with(body: { 'cin' => '50 158 635', 'email' => 'jan.hargas@slovensko.digital', 'family_name' => 'Hargaš',
        'given_name' => 'Ján', 'legal_subject_name' => 'Slovensko.Digital', 'mode' => 'api_mode',
        'password' => 'nejakeheslo', 'password_confirmation' => 'nejakeheslo',
        'person_formatted_address' => 'Koprivnická 9/B, 841 04 Bratislava', 'phone' => '+421903919123',
        'referral_code' => 'sf',
      }).to_return(status: 201)

    click_on 'Skúsiť dokončiť registráciu znova'

    expect(page).to have_content('Registrácia úspešná!')
  end
end
