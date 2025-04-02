# frozen_string_literal: true

Factory.define(:auth_log) do |f|
  f.uuid Faker::Internet.uuid
  f.client Faker::Internet.ip_v4_address
  f.user Faker::Internet.username
  f.result "success"
  f.provider "local"
  f.timestamps
end

Factory.define(auth_log_failure: :auth_log) do |f|
  f.result "failure"
end
