# frozen_string_literal: true

class Api::V1::Surf::EmailsController < Api::BaseController
  # Notes:
  # - Requires an access token.
  # - @current_user is the access token resource owner
  before_action :current_user

  def confirmation
    confirmation_params = { confirmation_token: @current_user.confirmation_token }
    confirmation_url = "/auth/confirmation?#{confirmation_params.to_query}"
    render json: {
      base_url: request.base_url,
      confirmation_url: confirmation_url,
      username: @current_user.account.username,
      email: @current_user.email,
    }
  end

  def welcome
    render json: {
      base_url: request.base_url,
      username: @current_user.account.username,
      email: @current_user.email,
    }
  end
end
