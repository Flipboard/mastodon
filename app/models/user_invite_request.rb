# frozen_string_literal: true

# == Schema Information
#
# Table name: user_invite_requests
#
#  id                 :bigint(8)        not null, primary key
#  user_id            :bigint(8)
#  text               :text
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  flipboard_username :string
#

class UserInviteRequest < ApplicationRecord
  TEXT_SIZE_LIMIT = 420

  belongs_to :user, inverse_of: :invite_request
  validates :text, presence: true, length: { maximum: TEXT_SIZE_LIMIT }
  validates :flipboard_username, allow_blank: true, length: { maximum: 128 }
end
