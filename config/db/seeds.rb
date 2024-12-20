# frozen_string_literal: true

# This seeds file should create the database records required to run the app.
#
# The code should be idempotent so that it can be executed at any time.
#
# To load the seeds, run `hanami db seed`. Seeds are also loaded as part of `hanami db prepare`.

# For example, if you have appropriate repos available:
#
#   category_repo = Hanami.app["repos.category_repo"]
#   category_repo.create(title: "General")
#
# Alternatively, you can use relations directly:
#
#   categories = Hanami.app["relations.categories"]
#   categories.insert(title: "General")

require "socket"

title = ENV.fetch("TITLE", "Yuzakan")
domain = ENV.fetch("DOMAIN", Socket.gethostname.split(".", 2)[1])
admin_username = ENV.fetch("ADMIN_USERNAME", "admin")
admin_password = ENV.fetch("ADMIN_PASSWORD", admin_username)
admin_groupname = ENV.fetch("ADMIN_GROUPNAME", admin_username)

# setup config
config_repo = Hanami.app["repos.config_repo"]
config_repo.set(title: title, domain: domain) unless config_repo.current

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
  local_adapter_params = {
    display_name: "ローカル",
    adapter: "local",
    order: "0",
    readable: true,
    writable: true,
    authenticatable: true,
    password_changeable: true,
    lockable: true,
    group: true,
  }
  provider_repo.set("local", **local_adapter_params)
end

# setup admin user and group
providers_read_group = Hanami.app["providers.read_group"]
group_providers = providers_read_group.call(admin_groupname, ["local"])
if group_providers.empty?
  providers_create_group = Hanami.app["providers.create_group"]
  providers_create_group.call(admin_groupname, ["local"], display_name: "管理者")
end
groups_sync = Hanami.app["groups.sync"]
groups_sync.call(admin_groupname)

unless get_user(admin_username)
  create_result = proider_create_user.call({
    **admin_user_params.slice(:username, :password),
    providers: ["local"],
    display_name: "ローカル管理者",
  })
  if create_result.failure?
    flash[:errors].concat(create_result.errors)
    return
  end

  admin_user = get_user(admin_user_params[:username])
  if admin_user.clearance_level < 5
    user_repo.update(admin_user.id,
      clearance_level: 5)
  end
  admin_password
end
