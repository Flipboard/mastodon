# frozen_string_literal: true

class AdminMailer < ApplicationMailer
  # Moderation mail each recipient can already switch off in their own settings,
  # mapped to the notification_emails.* key the unsubscribe endpoint toggles. The
  # software update and end of support mails are deliberately absent: they are
  # marked important rather than optional, and software_updates is a four-value
  # setting that a one-click POST cannot express.
  UNSUBSCRIBABLE_TYPES = {
    new_report: 'report',
    new_appeal: 'appeal',
    new_pending_account: 'pending_account',
    new_trends: 'trends',
  }.freeze

  layout 'admin_mailer'

  helper :accounts
  helper :languages

  before_action :process_params
  before_action :set_instance

  after_action :set_important_headers!, only: [:new_critical_software_updates, :end_of_support_out_of_support_warning]
  after_action :set_list_headers!, only: UNSUBSCRIBABLE_TYPES.keys

  around_action :set_locale

  default to: -> { @me.user_email }

  def new_report(report)
    @report = report

    mail subject: default_i18n_subject(instance: @instance, id: @report.id)
  end

  def new_appeal(appeal)
    @appeal = appeal

    mail subject: default_i18n_subject(instance: @instance, username: @appeal.account.username)
  end

  def new_pending_account(user)
    @account = user.account

    mail subject: default_i18n_subject(instance: @instance, username: @account.username)
  end

  def new_trends(links, tags, statuses)
    ActiveRecord::Associations::Preloader.new(records: [*links, *tags, *statuses], associations: [:trend]).call

    @links                  = links.filter { |link| link.trend.present? }
    @tags                   = tags.filter { |tag| tag.trend.present? }
    @statuses               = statuses.filter { |status| status.trend.present? }

    return unless @links.any? || @tags.any? || @statuses.any?

    mail subject: default_i18n_subject(instance: @instance)
  end

  def new_software_updates
    @software_updates = SoftwareUpdate.by_version

    mail subject: default_i18n_subject(instance: @instance)
  end

  def new_critical_software_updates
    @software_updates = SoftwareUpdate.urgent.by_version

    mail subject: default_i18n_subject(instance: @instance)
  end

  def end_of_support_three_months_warning
    @software_updates = SoftwareUpdate.by_version

    mail subject: default_i18n_subject(instance: @instance, branch: SoftwareDeprecation.current_branch)
  end

  def end_of_support_two_weeks_warning
    @software_updates = SoftwareUpdate.by_version

    mail subject: default_i18n_subject(instance: @instance, branch: SoftwareDeprecation.current_branch)
  end

  def end_of_support_out_of_support_warning
    @software_updates = SoftwareUpdate.by_version

    mail subject: default_i18n_subject(instance: @instance, branch: SoftwareDeprecation.current_branch)
  end

  def auto_close_registrations
    mail subject: default_i18n_subject(instance: @instance)
  end

  private

  def process_params
    @me = params[:recipient]
  end

  def set_instance
    @instance = Rails.configuration.x.local_domain
  end

  def set_locale(&block)
    locale_for_account(@me, &block)
  end

  def set_important_headers!
    headers(
      'Importance' => 'high',
      'Priority' => 'urgent',
      'X-Priority' => '1'
    )
  end

  # Mirrors NotificationMailer#set_list_headers!. Without it this mail carries
  # Precedence: list and no way to unsubscribe, which is what bulk sender rules
  # object to, even though the recipient can turn it off in their settings.
  def set_list_headers!
    type = UNSUBSCRIBABLE_TYPES[action_name.to_sym]
    user = @me&.user
    return if type.blank? || user.nil?

    headers(
      'List-ID' => "<#{type}.#{@me.username}.#{Rails.configuration.x.local_domain}>",
      'List-Unsubscribe-Post' => 'List-Unsubscribe=One-Click',
      'List-Unsubscribe' => "<#{unsubscribe_url(token: user.to_sgid(for: 'unsubscribe').to_s, type: type)}>"
    )
  end
end
