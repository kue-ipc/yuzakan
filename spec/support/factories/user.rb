# frozen_string_literal: true

Factory.define(:user) do |f|
  f.name Faker::Internet.username
  f.display_name Faker::Name.name
  f.email Faker::Internet.email
  f.note Faker::Lorem.paragraph
  f.clearance_level 1 # default
  f.prohibited false # default
  f.deleted false # default
  f.deleted_at nil
  f.timestamps
end

Factory.define(user_nil: :user) do |f|
  f.display_name nil
  f.email nil
  f.note nil
end
