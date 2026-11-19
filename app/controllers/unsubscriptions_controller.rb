# frozen_string_literal: true

class UnsubscriptionsController < ApplicationController
  layout 'auth'

  skip_before_action :require_functional!

  before_action :set_recipient
  before_action :set_type
  before_action :set_scope
  before_action :require_type_if_user!

  protect_from_forgery with: :null_session

  def show; end

  def create
    case @scope
    when :user
      @recipient.settings[@type] = false
      @recipient.save!
    when :email_subscription
      @recipient.destroy!
    end
  end

  private

  def set_recipient
    @recipient = GlobalID::Locator.locate_signed(params[:token], for: 'unsubscribe')
    not_found unless @recipient
  end

  def set_scope
    if @recipient.is_a?(User)
      @scope = :user
    elsif @recipient.is_a?(EmailSubscription)
      @scope = :email_subscription
    else
      not_found
    end
  end

  def set_type
    @type = email_type_from_param
    # The views label the mail being switched off. @type is the settings key
    # (notification_emails.foo) and the label scope already ends in
    # notification_emails, so rendering @type looks up
    # unsubscriptions.notification_emails.notification_emails.foo and misses.
    @type_name = params[:type] if @type.present?
  end

  def require_type_if_user!
    not_found if @recipient.is_a?(User) && @type.blank?
  end

  def email_type_from_param
    case params[:type]
    when 'follow', 'reblog', 'favourite', 'mention', 'follow_request',
         'report', 'appeal', 'pending_account', 'trends'
      "notification_emails.#{params[:type]}"
    end
  end
end
