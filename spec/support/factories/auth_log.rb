# frozen_string_literal: true

Factory.define(:auth_log) do |f|
  f.uuid { fake(:internet, :uuid) }
  f.client { fake(:internet, :ip_v4_address) }
  f.user { fake(:internet, :username) }
  f.type "auth"
  f.result "success"
  f.service "local"
  f.timestamps
end

Factory.define(failure_auth_log: :auth_log) do |f|
  f.result "failure"
  f.serivec ""
end
