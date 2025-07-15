# frozen_string_literal: true

Factory.define(:action_log) do |f|
  f.uuid { fake(:internet, :uuid) }
  f.client { fake(:internet, :ip_v4_address) }
  f.user { fake(:internet, :username) }
  f.action "Yuzakan::Actions::Dummy"
  f.method "GET"
  f.path "/dummy"
  f.status 200
  f.timestamps
end
