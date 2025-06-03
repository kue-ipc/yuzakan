# frozen_string_literal: true

require "socket"
require "dry/monads"

include Dry::Monads[:result]

title = ENV.fetch("TITLE", "Yuzakan")
description = ENV.fetch("SUB_TITLE", "アカウント管理システム")

admin_username = ENV.fetch("ADMIN_USERNAME", "admin")
admin_password = ENV.fetch("ADMIN_PASSWORD", admin_username)
admin_groupname = ENV.fetch("ADMIN_GROUPNAME", admin_username)

# setup config
config_repo = Hanami.app["repos.config_repo"]
config_repo.set(title: title, description: description) unless config_repo.current

# setup networks
network_repo = Hanami.app["repos.network_repo"]
if network_repo.count.zero?
  [
    "127.0.0.0/8",
    "10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16",
    "::1",
    "fc00::/7",
  ].each do |address|
    network_repo.set(address, clearance_level: 5, trusted: true)
  end
  ["0.0.0.0/0", "::/0"].each do |address|
    network_repo.set(address, clearance_level: 1, trusted: false)
  end
end

# setup local provider
provider_repo = Hanami.app["repos.provider_repo"]
unless provider_repo.get("local")
  local_provider_params = {
    display_name: "ローカル",
    order: 0,
    adapter: "local",
    params: {},
    readable: true,
    writable: true,
    authenticatable: true,
    password_changeable: true,
    lockable: true,
    group: true,
  }
  provider_repo.set("local", **local_provider_params)
end

# setup admin user and group
Hanami.app["providers.read_group"].call(admin_groupname, ["local"]) =>
  Success(group_providers)
if group_providers["local"].nil?
  Hanami.app["providers.create_group"].call(admin_groupname, ["local"],
    display_name: "管理者") in Success(_)
end

Hanami.app["providers.read_user"].call(admin_username, ["local"]) =>
  Success(user_providers)
if user_providers["local"].nil?
  Hanami.app["providers.create_user"].call(admin_username, ["local"],
    password: admin_password, display_name: "ローカル管理者",
    primary_group: admin_groupname, groups: []) in Success(_)
end

Hanami.app["management.sync_group"].call(admin_groupname) =>
  Success(admin_group)
Hanami.app["management.sync_user"].call(admin_username) => Success(admin_user)

if admin_user.clearance_level < 5
  Hanami.app["repos.user_repo"].set(admin_username, clearance_level: 5)
end
