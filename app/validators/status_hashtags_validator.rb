# frozen_string_literal: true

class StatusHashtagsValidator < ActiveModel::Validator
  MAX_HASHTAGS = ENV.fetch('MAX_HASHTAGS', 3).to_i

  def validate(status)
    return unless status.local? && !status.reblog?
    return if MAX_HASHTAGS <= 0

    hashtag_count = Extractor.extract_hashtags(status.text).size
    status.errors.add(:text, I18n.t('statuses.too_many_hashtags', max: MAX_HASHTAGS)) if hashtag_count > MAX_HASHTAGS
  end
end
