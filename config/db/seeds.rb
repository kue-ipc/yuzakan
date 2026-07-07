# frozen_string_literal: true

require "socket"
require "dry/monads"

include Dry::Monads[:result]

title = ENV.fetch("TITLE", "Yuzakan")

admin_username = ENV.fetch("ADMIN_USERNAME", "admin")
admin_password = ENV.fetch("ADMIN_PASSWORD", admin_username)
admin_groupname = ENV.fetch("ADMIN_GROUPNAME", admin_username)

# cache clear
Hanami.app["cache_store"].clear

# setup config
config_repo = Hanami.app["repos.config_repo"]
config_repo.create(title:) unless config_repo.created?

# setup networks
network_repo = Hanami.app["repos.network_repo"]
if network_repo.first.nil?
  [
    "127.0.0.0/8",
    "10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16",
    "::1",
    "fc00::/7",
  ].each do |address|
    network_repo.create(ip: IPAddr.new(address), clearance_level: 5, trusted: true)
  end
  ["0.0.0.0/0", "::/0"].each do |address|
    network_repo.create(ip: IPAddr.new(address), clearance_level: 1, trusted: false)
  end
end

# setup local service
service_repo = Hanami.app["repos.service_repo"]
local_service = service_repo.get("local") || service_repo.set!("local",
  order: 0,
  adapter: "local",
  params: {},
  readable: true,
  writable: true,
  authenticatable: true,
  password_changeable: true,
  lockable: true,
  group: true)

# setup admin user and group for local service
case Hanami.app["services.read_group"].call(local_service, admin_groupname)
in Success(nil)
  Hanami.app["services.create_group"].call(local_service, admin_groupname) => Success(_)
in Success(_)
  # do nothing
end

case Hanami.app["services.read_user"].call(local_service, admin_username)
in Success(nil)
  params = {primary_group: admin_groupname, groups: []}
  Hanami.app["services.create_user"].call(local_service, admin_username, admin_password, **params) => Success(_)
in Success(_)
  # do nothing
end

Hanami.app["management.sync_user"].call(admin_username) => Success(admin_user)
Hanami.app["repos.user_repo"].put!(admin_username, clearance_level: 5) if admin_user.clearance_level < 5
