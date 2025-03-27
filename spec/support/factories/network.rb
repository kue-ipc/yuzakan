# frozen_string_literal: true

Factory.define(:network) do |f|
  f.ip IPAddr.new("0.0.0.0/0")
  f.clearance_level 1 # default
  f.trusted false # default
  f.timestamps
end

Factory.define(network_ipv4_all: :network) do |f|
  # same
end

Factory.define(network_ipv6_all: :network) do |f|
  f.ip IPAddr.new("::/0")
end

Factory.define(network_ipv4_loopback: :network) do |f|
  f.ip IPAddr.new("127.0.0.0/8")
  f.clearance_level 5
  f.trusted true
end

Factory.define(network_ipv6_loopback: :network) do |f|
  f.ip IPAddr.new("::1")
  f.clearance_level 5
  f.trusted true
end

Factory.define(network_ipv4_pn_a: :network) do |f|
  f.ip IPAddr.new("0.0.0.0/8")
  f.clearance_level 1
  f.trusted true
end

Factory.define(network_ipv4_pn_b: :network) do |f|
  f.ip IPAddr.new("172.16.0.0/12")
  f.clearance_level 1
  f.trusted true
end

Factory.define(network_ipv4_pn_c: :network) do |f|
  f.ip IPAddr.new("192.168.0.0/16")
  f.clearance_level 1
  f.trusted true
end

Factory.define(network_ipv6_ula: :network) do |f|
  f.ip IPAddr.new("fc::/7")
  f.clearance_level 1
  f.trusted true
end
