# frozen_string_literal: true

require "socket"
require "dry/monads"

include Dry::Monads[:result]

title = ENV.fetch("TITLE", "Yuzakan")
description = ENV.fetch("SUB_TITLE", "アカウント管理システム")

admin_username = ENV.fetch("ADMIN_USERNAME", "admin")
admin_password = ENV.fetch("ADMIN_PASSWORD", admin_username)
admin_groupname = ENV.fetch("ADMIN_GROUPNAME", admin_username)

# FIXME: 予めi18nをロードしておかないと、jaが読み込まれない。バグ？
Hanami.app["i18n"]

# cache clear
Hanami.app["cache_store"].clear

# setup config
config_repo = Hanami.app["repos.config_repo"]
config_repo.create(title: title, description: description) unless config_repo.created?

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
local_service = service_repo.get("local") || service_repo.set("local",
  label: "ローカル",
  order: 0,
  adapter: "local",
  params: {},
  readable: true,
  writable: true,
  authenticatable: true,
  password_changeable: true,
  lockable: true,
  group: true)

# setup admin user and group
case Hanami.app["services.read_group"].call(local_service, admin_groupname)
in Success(nil)
  params = {label: "管理者"}
  Hanami.app["services.create_group"].call(local_service, admin_groupname, **params) => Success(_)
in Success(_)
  # do nothing
end

case Hanami.app["services.read_user"].call(local_service, admin_username)
in Success(nil)
  params = {label: "ローカル管理者", primary_group: admin_groupname, groups: []}
  Hanami.app["services.create_user"].call(local_service, admin_username, admin_password, **params) => Success(_)
in Success(_)
  # do nothing
end

Hanami.app["management.sync_user"].call(admin_username) => Success(admin_user)
Hanami.app["repos.user_repo"].set(admin_username, clearance_level: 5) if admin_user.clearance_level < 5
