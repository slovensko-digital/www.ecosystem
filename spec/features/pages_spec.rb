require 'rails_helper'

RSpec.describe 'Pages' do
  describe 'homepage' do
    let(:schemas) { HomepageController::SCHEMAS }

    before(:example) { Rails.cache.delete('dump_sizes') }

    context 'with successful dump sizes fetch' do
      before(:example) do
        schemas.each { |schema| stub_request(:head, "http://s3.eu-central-1.amazonaws.com/ekosystem-slovensko-digital-dumps/#{schema}.sql.gz").to_return(status: 200, headers: { 'content-length' => '1000000000' }) }
      end

      it 'works and shows actual dump sizes' do
        visit root_path

        expect(page).to have_content('Služby')
        expect(page).to have_content('Autoform')
        expect(page).to have_content('Datahub')

        schemas.each { |schema| expect(page).to have_link("#{schema}.sql.gz.torrent (950 MB)", href: "https://s3.eu-central-1.amazonaws.com/ekosystem-slovensko-digital-dumps/#{schema}.sql.gz?torrent") }
      end
    end

    context 'with unsuccessful dump sizes fetch' do
      before(:example) do
        schemas.each { |schema| stub_request(:head, "http://s3.eu-central-1.amazonaws.com/ekosystem-slovensko-digital-dumps/#{schema}.sql.gz").to_return(status: 500) }
      end

      it 'works and shows question marks instead of dump sizes' do
        visit root_path

        expect(page).to have_content('Služby')
        expect(page).to have_content('Autoform')
        expect(page).to have_content('Datahub')

        schemas.each { |schema| expect(page).to have_link("#{schema}.sql.gz.torrent (? MB)", href: "https://s3.eu-central-1.amazonaws.com/ekosystem-slovensko-digital-dumps/#{schema}.sql.gz?torrent") }
      end
    end
  end

  describe 'sluzby' do

    describe 'autoform' do
      it 'works' do
        visit 'sluzby/autoform'

        expect(page).to have_content('Autoform')
        expect(page).to have_content('Integračný manuál')
        expect(page).to have_content('Registrácia')
      end
    end

    describe 'datahub' do
      it 'works' do
        visit 'sluzby/datahub'

        expect(page).to have_content('Datahub')
        expect(page).to have_content('SQL')
        expect(page).to have_content('Registrácia')
      end
    end
  end

  describe 'open-api' do
    it 'works' do
      visit 'otvorene-api'

      expect(page).to have_content('Otvorené API')

      expect(page).to have_content('Synchronizačné API')
      expect(page).to have_content('Register právnických osôb')
      expect(page).to have_content('Centrálny register zmlúv')
      expect(page).to have_content('Obchodný vestník')
      expect(page).to have_content('Register účtovných závierok')
    end
  end

  describe 'otvorene-data' do
    it 'works' do
      visit 'otvorene-data'

      expect(page).to have_content('Otvorené dáta')

      expect(page).to have_content('rpo.')
      expect(page).to have_content('crz.')
      expect(page).to have_content('ov.')
      expect(page).to have_content('fs.')
      expect(page).to have_content('ruz.')
      expect(page).to have_content('socpoist.')
      expect(page).to have_content('vszp.')
      expect(page).to have_content('upvs.')
      expect(page).to have_content('itms.')
    end
  end

  describe 'premium-api' do
    it 'works' do
      visit 'premiove-api'

      expect(page).to have_content('Prémiové API')

      expect(page).to have_content('Overenie prístupu')
      expect(page).to have_content('Právnické osoby')
    end
  end

  describe 'premium-data' do
    it 'works' do
      visit 'premiove-data'

      expect(page).to have_content('Prémiové dáta')
      expect(page).to have_content('Právnické osoby')

      expect(page).to have_content('datahub.')
    end
  end

  describe 'podmienky' do
    it 'works' do
      visit 'podmienky'

      expect(page).to have_content('Podmienky používania datasetov')
    end
  end

  describe 'page 404' do
    it 'works' do
      visit '404'

      expect(page).to have_content('Stránka sa nenašla')
    end
  end

  describe 'page 500' do
    it 'works' do
      visit '500'

      expect(page).to have_content('niečo sa pokazilo')
    end
  end

  describe 'page 422' do
    it 'works' do
      visit '422'

      expect(page).to have_content('Akcia na stránke nebola povolená')
    end
  end
end
