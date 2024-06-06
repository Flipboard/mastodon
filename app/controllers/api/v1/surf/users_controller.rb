# frozen_string_literal: true

class Api::V1::Surf::UsersController < Api::BaseController
  before_action -> { doorkeeper_authorize! :read }
  before_action :require_user!

  def show
    # the user serializer skips fields
    # add the confirmation_token if it exists...
    user = @current_user.as_json
    user[:confirmation_token] = @current_user.confirmation_token unless @current_user.confirmed?
    render json: user
  end

  # Override require_user! because it prevents
  # unconfirmed user access and might need to
  # get the confirmation_token for sending the email
  protected
  def require_user!
    if !current_user
      render json: { error: 'This method requires an authenticated user' }, status: 422
    else
      update_user_sign_in
    end
  end
end
