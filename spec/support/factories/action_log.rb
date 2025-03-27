# frozen_string_literal: true

Factory.define(:action_log) do |f|
  f.uuid Faker::Internet.uuid
  f.client Faker::Internet.ip_v4_address
  f.user nil
  f.action "Yuzakan::Actions::Dummy"
  f.method "GET"
  f.path "/dummy"
  f.status nil
  f.timestamps
end
