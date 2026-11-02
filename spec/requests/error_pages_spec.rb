require 'rails_helper'

RSpec.describe 'Error pages', type: :request do
  # XHR, as a remote form submit is; a plain cross-origin GET for JS is rejected earlier by Rails
  let(:js) { { 'Accept' => 'text/javascript' } }

  it 'answers 404 to a non-HTML/JSON format' do
    get '/404', headers: js, xhr: true
    expect(response).to have_http_status(404)
  end

  it 'answers 422 to a non-HTML/JSON format' do
    get '/422', headers: js, xhr: true
    expect(response).to have_http_status(422)
  end

  it 'answers 500 to a non-HTML/JSON format' do
    get '/500', headers: js, xhr: true
    expect(response).to have_http_status(500)
  end
end
