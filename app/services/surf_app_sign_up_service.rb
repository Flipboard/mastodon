# frozen_string_literal: true

class SurfAppSignUpService < AppSignUpService
  def call(app, remote_ip, params)
    @app       = app
    @remote_ip = remote_ip
    @params    = params

    raise Mastodon::NotPermittedError unless allowed_registrations?

    ApplicationRecord.transaction do
      create_user!
      create_access_token!
    end

    @access_token
  end

  private

  def create_user!
    @user = User.new(
      user_params.merge(
        created_by_application: @app,
        sign_up_ip: @remote_ip,
        password_confirmation: user_params[:password],
        account_attributes: account_params,
        invite_request_attributes: invite_request_params
      )
    )
    # disable sending confirmation email
    @user.skip_confirmation_notification!
    @user.save!
  end
end

