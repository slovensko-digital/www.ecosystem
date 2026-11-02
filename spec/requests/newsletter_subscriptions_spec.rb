require 'rails_helper'

RSpec.describe 'Newsletter subscription', type: :request do
  it 'responds with JS on success' do
    allow(NewsletterSubscriptionService).to receive(:subscribe).with('jan@example.com')

    post newsletter_subscribe_path, params: { email: 'jan@example.com' }, xhr: true

    expect(response).to have_http_status(:ok)
    expect(response.media_type).to eq('text/javascript')
    expect(response.body).to include('#newsletter-success')
  end

  it 'responds with JS error on failure' do
    allow(NewsletterSubscriptionService).to receive(:subscribe).and_raise(StandardError)

    post newsletter_subscribe_path, params: { email: 'jan@example.com' }, xhr: true

    expect(response).to have_http_status(:bad_request)
    expect(response.media_type).to eq('text/javascript')
  end
end
