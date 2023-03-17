Fabricator(:user_invite_request) do
  user
  text { Faker::Lorem.sentence }
  flipboard_username { Faker::Lorem.sentence }
end
