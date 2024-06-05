# frozen_string_literal: true

require 'rails_helper'

describe StatusLengthValidator do
  describe '#validate' do
    it 'does not add errors onto remote statuses' do
      status = instance_double(Status, local?: false)
      subject.validate(status)
      expect(status).to_not receive(:errors)
    end

    it 'does not add errors onto local reblogs' do
      status = instance_double(Status, local?: false, reblog?: true)
      subject.validate(status)
      expect(status).to_not receive(:errors)
    end

    it 'adds an error when content warning is over 5000 characters' do
      status = instance_double(Status, spoiler_text: 'a' * 5020, text: '', errors: activemodel_errors, local?: true, reblog?: false)
      subject.validate(status)
      expect(status.errors).to have_received(:add)
    end

    it 'adds an error when text is over 5000 characters' do
      status = instance_double(Status, spoiler_text: '', text: 'a' * 5020, errors: activemodel_errors, local?: true, reblog?: false)
      subject.validate(status)
      expect(status.errors).to have_received(:add)
    end

    it 'adds an error when text and content warning are over 5000 characters total' do
      status = instance_double(Status, spoiler_text: 'a' * 2500, text: 'b' * 2501, errors: activemodel_errors, local?: true, reblog?: false)
      subject.validate(status)
      expect(status.errors).to have_received(:add)
    end

    it 'counts URLs as 23 characters flat' do
      text   = ('a' * 476) + " http://#{'b' * 30}.com/example"
      status = instance_double(Status, spoiler_text: '', text: text, errors: activemodel_errors, local?: true, reblog?: false)

      subject.validate(status)
      expect(status.errors).to_not have_received(:add)
    end

    it 'does not count non-autolinkable URLs as 23 characters flat' do
      text   = ('a' * 4976) + "http://#{'b' * 30}.com/example"
      status = instance_double(Status, spoiler_text: '', text: text, errors: activemodel_errors, local?: true, reblog?: false)

      subject.validate(status)
      expect(status.errors).to have_received(:add)
    end

    it 'does not count overly long URLs as 23 characters flat' do
      text = "http://example.com/valid?#{'#foo?' * 1000}"
      status = instance_double(Status, spoiler_text: '', text: text, errors: activemodel_errors, local?: true, reblog?: false)
      subject.validate(status)
      expect(status.errors).to have_received(:add)
    end

    it 'counts only the front part of remote usernames' do
      text   = ('a' * 475) + " @alice@#{'b' * 30}.com"
      status = instance_double(Status, spoiler_text: '', text: text, errors: activemodel_errors, local?: true, reblog?: false)

      subject.validate(status)
      expect(status.errors).to_not have_received(:add)
    end

    it 'does count both parts of remote usernames for overly long domains' do
      text   = "@alice@#{'b' * 5000}.com"
      status = instance_double(Status, spoiler_text: '', text: text, errors: activemodel_errors, local?: true, reblog?: false)

      subject.validate(status)
      expect(status.errors).to have_received(:add)
    end
  end

  private

  def activemodel_errors
    instance_double(ActiveModel::Errors, add: nil)
  end
end
