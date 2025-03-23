# frozen_string_literal: true

Factory.define(:config) do |f|
  f.title  Faker::Team.name
  f.domain Faker::Internet.domain_name
  f.contact_name Faker::Name.name
  f.contact_email Faker::Internet.email
  f.contact_phone Faker::PhoneNumber.phone_number
  f.timestamps
end
