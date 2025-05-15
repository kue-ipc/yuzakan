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

Factory.define(user_with_nil: :user) do |f|
  f.display_name nil
  f.email nil
  f.note nil
end

Factory.define(guest: :user) do |f|
  f.clearance_level 0
end

# user with clearance level 1

Factory.define(observer: :user) do |f|
  f.clearance_level 2
end

Factory.define(operator: :user) do |f|
  f.clearance_level 3
end

Factory.define(administrator: :user) do |f|
  f.clearance_level 4
end

Factory.define(superuser: :user) do |f|
  f.clearance_level 5
end
