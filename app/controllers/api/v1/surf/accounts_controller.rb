# frozen_string_literal: true

class Api::V1::Surf::AccountsController < Api::BaseController
  before_action -> { doorkeeper_authorize! :write, :'write:accounts' }, only: [:create]
  before_action :check_enabled_registrations, only: [:create]
  skip_before_action :require_authenticated_user!, only: :create

  def create
    token = SurfAppSignUpService.new.call(doorkeeper_token.application, request.remote_ip, account_params)
    response = Doorkeeper::OAuth::TokenResponse.new(token)

    headers.merge!(response.headers)
    self.response_body = Oj.dump(response.body)
    self.status        = response.status
  rescue ActiveRecord::RecordInvalid => e
    render json: ValidationErrorFormatter.new(e, 'account.username': :username, 'invite_request.text': :reason).as_json, status: 422
  end

  private

  def account_params
    params.permit(:username, :email, :password, :agreement, :locale, :reason, :time_zone)
  end

  def check_enabled_registrations
    # Skip this check for now...
    # forbidden if single_user_mode? || omniauth_only? || !allowed_registrations?
    # Instead check if registrations are enabled
    registrations_enabled = Rails.configuration.x.surf[:registrations_enabled]
    logger.info 'Surf Registrations Disabled. Returning Forbidden' unless registrations_enabled
    return forbidden unless registrations_enabled

    # Now chheck if the X-Surf-Registration-Token is present and valid
    registration_token = request.headers['X-Surf-Registration-Token']
    expected_token = Rails.configuration.x.surf[:registration_token]
    valid_token = registration_token.present? && expected_token.present? && registration_token == expected_token
    logger.info 'Surf Registration Token Invalid. Returning Forbidden' unless valid_token
    forbidden unless valid_token
  end

  def allowed_registrations?
    Setting.registrations_mode != 'none'
  end

  def omniauth_only?
    ENV['OMNIAUTH_ONLY'] == 'true'
  end
end
