# frozen_string_literal: true

def db_clear
  UserRepository.new.clear
  LocalUserRepository.new.clear
  ServiceRepository.new.clear
  ConfigRepository.new.clear
  NetworkRepository.new.clear
end

def db_initialize
  network_repository = NetworkRepository.new
  ["127.0.0.0/8",
    "10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16",
    "::1",
    "fc00::/7",].each do |address|
    network_repository.create_or_update_by_address(address,
      {clearance_level: 5,
       trusted: true,})
  end
  ["0.0.0.0/0", "::/0"].each do |address|
    network_repository.create_or_update_by_address(address,
      {clearance_level: 1,
       trusted: false,})
  end

  service_repository = ServiceRepository.new
  service_repository.create({
    name: "local",
    label: "ローカル",
    order: "0",
    adapter: "local",
    readable: true,
    writable: true,
    authenticatable: true,
    password_changeable: true,
    lockable: true,
  })
  service_repository.create({
    name: "dummy",
    label: "ダミー",
    adapter: "dummy",
  })
  local_service = service_repository.find_with_adapter_by_name("local")
  local_service.create("admin", "pass",
    label: "ローカル管理者",
    email: "admin@example.jp")
  local_service.create("user", "word",
    label: "一般ユーザー",
    email: "user@example.jp")
  user_repository.create(usenrname: "admin", clearance_level: 5)
  config_repository.current_create({title: "テストサイト", maintenace: false})
  ServiceAuthenticate.new(client: "::1",
    app: "test").call({
      username: "user", password: "word",
    })
end

def db_reset
  db_clear
  db_initialize
end
