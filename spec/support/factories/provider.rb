# frozen_string_literal: true

Factory.define(:provider) do |f|
  f.name Faker::Internet.username
  f.display_name Faker::Name.name
  f.description Faker::Lorem.paragraph
  f.order 1
  f.adapter "dummy"
  f.params({})
  f.readable false # default
  f.writable false # default
  f.authenticatable false # default
  f.password_changeable false # default
  f.lockable false # default
  f.group false # default
  f.individual_password false # default
  f.self_management false # default
  f.timestamps
end

Factory.define(provdire_with_nil: :provider) do |f|
  f.display_name nil
  f.description nil
end

Factory.define(mock_provdire: :provider) do |f|
  f.name "mock"
  f.adapter "mock"
  f.readable true
  f.writable true
  f.authenticatable true
  f.password_changeable true
  f.lockable true
  f.group true
end
