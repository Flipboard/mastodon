# frozen_string_literal: true

class Api::V1::Surf::UsersController < Api::BaseController
  before_action -> { doorkeeper_authorize! :write }, only: [:sign_in, :sign_out]
  before_action -> { doorkeeper_authorize! :read }
  before_action :require_user!, except: [:sign_in]

  def sign_in
    # Requires: app access_token
    @current_user = User.find_by(email: params[:email])
    raise(ActiveRecord::RecordNotFound) unless @current_user&.valid_password?(params[:password])

    require_not_suspended!

    # checks if they have an existing, valid access token
    token = Doorkeeper::AccessToken.find_by(
      resource_owner_id: @current_user.id,
      application_id: doorkeeper_token.application,
      revoked_at: nil
    )
    if token.nil?
      token = Doorkeeper::AccessToken.create!(
        application: doorkeeper_token.application,
        resource_owner_id: @current_user.id,
        scopes: doorkeeper_token.application.scopes,
        expires_in: Doorkeeper.configuration.access_token_expires_in,
        use_refresh_token: Doorkeeper.configuration.refresh_token_enabled?
      )
    end

    update_user_sign_in
    prepare_returning_user!

    # prepare response
    response = Doorkeeper::OAuth::TokenResponse.new(token)
    headers.merge!(response.headers)
    self.response_body = Oj.dump(response.body)
    self.status        = response.status
  end

  def sign_out
    # Requires: user access_token
    revoke_access!
    render json: { message: 'All access tokens revoked.' }, status: 200
  end

  protected

  def revoke_access!
    # this method revokes all tokens for the current user
    Doorkeeper::AccessToken.by_resource_owner(@current_user).in_batches do |batch|
      batch.update_all(revoked_at: Time.now.utc) # rubocop:disable Rails/SkipsModelValidations
    end
  end

  def require_user!
    # Override require_user! because it prevents
    # unconfirmed user access and might need to
    # get the confirmation_token for sending the email
    if current_user
      update_user_sign_in
    else
      render json: { error: 'This method requires an authenticated user' }, status: 422
    end
  end

  def prepare_new_user!
    BootstrapTimelineWorker.perform_async(@current_user.account_id)
    ActivityTracker.increment('activity:accounts:local')
    ActivityTracker.record('activity:logins', @current_user.id)
    TriggerWebhookWorker.perform_async('account.approved', 'Account', @current_user.account_id)
  end

  def prepare_returning_user!
    ActivityTracker.record('activity:logins', @current_user.id)
  end
end

