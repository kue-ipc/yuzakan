# frozen_string_literal: true

Factory.define(:network) do |f|
  f.ip IPAddr.new("0.0.0.0/0")
  f.clearance_level 5
  f.trusted true
  f.timestamps
end

Factory.define(network_v6: :network) do |f|
  f.ip IPAddr.new("::/0")
  f.clearance_level 5
  f.trusted true
  f.timestamps
end

Factory.define(network_level0: :network) do |f|
  f.ip IPAddr.new("0.0.0.0/8")
  f.clearance_level 0
  f.trusted true
  f.timestamps
end

Factory.define(network_level1: :network) do |f|
  f.ip IPAddr.new("0.0.0.0/8")
  f.clearance_level 1
  f.trusted true
  f.timestamps
end

Factory.define(network_level2: :network) do |f|
  f.ip IPAddr.new("0.0.0.0/8")
  f.clearance_level 2
  f.trusted true
  f.timestamps
end

Factory.define(network_level3: :network) do |f|
  f.ip IPAddr.new("0.0.0.0/8")
  f.clearance_level 3
  f.trusted true
  f.timestamps
end

Factory.define(network_level4: :network) do |f|
  f.ip IPAddr.new("0.0.0.0/8")
  f.clearance_level 4
  f.trusted true
  f.timestamps
end

Factory.define(network_untrusted: :network) do |f|
  f.ip IPAddr.new("0.0.0.0/0")
  f.clearance_level 5
  f.trusted false
  f.timestamps
end
