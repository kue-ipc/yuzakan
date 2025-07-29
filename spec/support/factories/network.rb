# frozen_string_literal: true

Factory.define(:network) do |f|
  f.ip IPAddr.new("0.0.0.0/0")
  f.clearance_level 1 # default
  f.trusted false # default
  f.timestamps
end

Factory.define(trusted_network: :network) do |f|
  f.clearance_level 5
  f.trusted true
end

Factory.define(ipv4_all_network: :network) do |f|
  # same default
end

Factory.define(ipv6_all_network: :network) do |f|
  f.ip IPAddr.new("::/0")
end

Factory.define(ipv4_loopback_network: :trusted_network) do |f|
  f.ip IPAddr.new("127.0.0.0/8")
end

Factory.define(ipv6_loopback_network: :trusted_network) do |f|
  f.ip IPAddr.new("::1/128")
end

Factory.define(ipv4_pn_a_network: :trusted_network) do |f|
  f.ip IPAddr.new("10.0.0.0/8")
end

Factory.define(ipv4_pn_b_network: :trusted_network) do |f|
  f.ip IPAddr.new("172.16.0.0/12")
end

Factory.define(ipv4_pn_c_network: :trusted_network) do |f|
  f.ip IPAddr.new("192.168.0.0/16")
end

Factory.define(ipv6_ula_network: :trusted_network) do |f|
  f.ip IPAddr.new("fc00::/7")
end
