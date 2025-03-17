# frozen_string_literal: true

Factory.define(:activity_log) do |f|
  f.uuid Faker::Internet.uuid
  f.client Faker::Internet.ip_v4_address
  f.user Faker::Internet.username
  f.action "Yuzakan::Actions::Dummy"
  f.method "GET"
  f.path "/dummy"
  f.status 200
  f.timestamps
end
