# frozen_string_literal: true

Factory.define(:user) do |f|
  f.name Faker::Internet.username
  f.display_name Faker::Name.name
  f.email Faker::Internet.email
  f.timestamps
end
