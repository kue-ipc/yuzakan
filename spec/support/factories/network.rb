# frozen_string_literal: true

Factory.define(:network) do |f|
  f.ip IPAddr.new("0.0.0.0/0")
  f.clearance_level 1 # default
  f.trusted false # default
  f.timestamps
end

Factory.define(network_trusted: :network) do |f|
  f.clearance_level 5
  f.trusted true
end

Factory.define(network_ipv4_all: :network) do |f|
  # same default
end

Factory.define(network_ipv6_all: :network) do |f|
  f.ip IPAddr.new("::/0")
end

Factory.define(network_ipv4_loopback: :network_trusted) do |f|
  f.ip IPAddr.new("127.0.0.0/8")
end

Factory.define(network_ipv6_loopback: :network_trusted) do |f|
  f.ip IPAddr.new("::1")
end

Factory.define(network_ipv4_pn_a: :network_trusted) do |f|
  f.ip IPAddr.new("10.0.0.0/8")
end

Factory.define(network_ipv4_pn_b: :network_trusted) do |f|
  f.ip IPAddr.new("172.16.0.0/12")
end

Factory.define(network_ipv4_pn_c: :network_trusted) do |f|
  f.ip IPAddr.new("192.168.0.0/16")
end

Factory.define(network_ipv6_ula: :network_trusted) do |f|
  f.ip IPAddr.new("fc00::/7")
end
