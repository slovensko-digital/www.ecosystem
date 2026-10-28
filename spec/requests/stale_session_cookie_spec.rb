require 'rails_helper'

RSpec.describe 'Stale session cookie', type: :request do
  it 'ignores an undecryptable session cookie' do
    cookies['_ecosystem_session'] = 'garbage--abc'

    get '/podmienky'

    expect(response).to have_http_status(:ok)
    expect(response.body).to include('Podmienky používania datasetov')
  end
end
