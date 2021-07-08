class RegistrationsController < ApplicationController
  include RegistrationsHelper

  def create
    render :create and return unless registration.valid?(:submit)

    if recaptcha_valid?
      registration.finish and render :success
    else
      registration.checkbox_captcha! and render :create
    end
  end

  private

  def recaptcha_valid?
    if registration.checkbox_captcha
      verify_checkbox_captcha
    else
      verify_invisible_captcha
    end
  end

  def verify_checkbox_captcha
    verify_recaptcha(message: 'Skúste to ešte raz.', secret_key: ENV.fetch('RECAPTCHA_SECRET_KEY_V2_CHECKBOX'), model: registration)
  end

  def verify_invisible_captcha
    verify_recaptcha(message: 'Potvrďte, prosím, že nie ste robot.', minimum_score: 0.5, action: recaptcha_action, model: registration)
  end

  def registration_params
    params.require(:registration).permit(:service, :email, :checkbox_captcha)
  end

  def registration
    @registration ||= Registration.new(registration_params)
  end
end
