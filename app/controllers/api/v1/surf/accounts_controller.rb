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
    forbidden if single_user_mode? || omniauth_only? || !allowed_registrations?
  end

  def allowed_registrations?
    Setting.registrations_mode != 'none'
  end

  def omniauth_only?
    ENV['OMNIAUTH_ONLY'] == 'true'
  end
end

