# frozen_string_literal: true

class Api::V1::Surf::AccountsController < Api::BaseController
    include RegistrationHelper

    before_action -> { doorkeeper_authorize! :write, :'write:accounts' }, only: [:create]
    before_action :check_enabled_registrations, only: [:create]
    skip_before_action :require_authenticated_user!, only: :create

    def create
      user, token    = SurfAppSignUpService.new.call(doorkeeper_token.application, request.remote_ip, account_params)
      response = Doorkeeper::OAuth::TokenResponse.new(token)
      user['oauth'] = response.body

      headers.merge!(response.headers)
      self.response_body = Oj.dump(user)
      self.status        = response.status
    rescue ActiveRecord::RecordInvalid => e
      render json: ValidationErrorFormatter.new(e, 'account.username': :username, 'invite_request.text': :reason).as_json, status: 422
    end

    private

    def account_params
      params.permit(:username, :email, :password, :agreement, :locale, :reason, :time_zone, :invite_code)
    end

    def invite
      Invite.find_by(code: params[:invite_code]) if params[:invite_code].present?
    end

    def check_enabled_registrations
      forbidden unless allowed_registration?(request.remote_ip, invite)
    end
  end