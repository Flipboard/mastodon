# frozen_string_literal: true

require 'rails_helper'

RSpec.describe StatusHashtagsValidator do
  describe '#validate' do
    before { stub_const("#{described_class}::MAX_HASHTAGS", 3) }

    it 'does not add errors onto remote statuses' do
      status = status_double(text: '#a #b #c #d', local: false)

      subject.validate(status)

      expect(status.errors).to_not have_received(:add)
    end

    it 'does not add errors onto local reblogs' do
      status = status_double(text: '#a #b #c #d', reblog: true)

      subject.validate(status)

      expect(status.errors).to_not have_received(:add)
    end

    it 'does not add errors when hashtag count is within limit' do
      status = status_double(text: '#one #two #three')

      subject.validate(status)

      expect(status.errors).to_not have_received(:add)
    end

    it 'does not add errors when there are no hashtags' do
      status = status_double(text: 'just some text')

      subject.validate(status)

      expect(status.errors).to_not have_received(:add)
    end

    it 'adds an error when hashtag count exceeds limit' do
      status = status_double(text: '#one #two #three #four')

      subject.validate(status)

      expect(status.errors).to have_received(:add)
        .with(:text, I18n.t('statuses.too_many_hashtags', max: 3))
    end

    context 'when MAX_HASHTAGS is 0 (disabled)' do
      before { stub_const("#{described_class}::MAX_HASHTAGS", 0) }

      it 'does not add errors regardless of hashtag count' do
        status = status_double(text: '#a #b #c #d #e #f')

        subject.validate(status)

        expect(status.errors).to_not have_received(:add)
      end
    end
  end

  private

  def status_double(text:, local: true, reblog: false)
    instance_double(
      Status,
      text: text,
      local?: local,
      reblog?: reblog,
      errors: instance_double(ActiveModel::Errors, add: nil)
    )
  end
end
