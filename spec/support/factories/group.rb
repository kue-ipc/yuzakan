# frozen_string_literal: true

Factory.define(:group) do |f|
  f.name Faker::Internet.username
  f.display_name Faker::Music::RockBand.name
  f.note Faker::Lorem.paragraph
  f.basic false # default
  f.prohibited false # default
  f.deleted false # default
  f.deleted_at nil
  f.timestamps
end

Factory.define(group_with_nil: :group) do |f|
  f.display_name nil
  f.note nil
end
