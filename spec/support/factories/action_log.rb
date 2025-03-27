# frozen_string_literal: true

Factory.define(:action_log) do |f|
  f.uuid Faker::Internet.uuid
  f.client Faker::Internet.ip_v4_address
  f.user Faker::Internet.username
  f.action "Yuzakan::Actions::Dummy"
  f.method "GET"
  f.path "/dummy"
  f.status 200
  f.timestamps
end

Factory.define(action_log_nil: :action_log) do |f|
  f.user nil
  f.status nil
end
