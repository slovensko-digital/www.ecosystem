class RegistrationsController < ApplicationController
  include RegistrationsHelper

  def create
    @registration ||= new_registration(registration_params)

    if @registration.save { validate_captcha! }
      render :create
    else
      render :new
    end
  end

  private

  def validate_captcha!
    captcha_result = verify_recaptcha(minimum_score: 0.5, action: recaptcha_action(@registration.service), model: @registration, message: 'Nastala chyba. Ak problém pretrváva aj v inom prehliadači alebo zariadení, kontaktujte nás.')
    @registration.score = recaptcha_reply['score']

    captcha_result
  end

  def registration_params
    params.require(:registration).permit(:email, :service, :score, :domain)
  end
end
