# frozen_string_literal: true

class Api::V1::Surf::EmailsController < Api::BaseController

  # Notes:
  # - Requires an access token.
  # = @current_user is the access token resource owner

  before_action :current_user

  def confirmation

    # Use the normal mastodon instance urls to confirm for now...
    # Once we know the routes for surf we can change
    render json: {
      base_url: request.base_url,
      confirmation_url: '/auth/confirmation?confirmation_token=%s' % [
        request.base_url,
        @current_user.confirmation_token,
      ],
      username: @current_user.account.username,
      email: @current_user.email,
    }
  end
end