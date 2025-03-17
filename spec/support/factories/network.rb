# frozen_string_literal: true

Factory.define(:network) do |f|
  f.ip IPAddr.new(Faker::Internet.ip_v4_cidr)
  f.clearance_level 5
  f.trusted true
  f.timestamps
end
