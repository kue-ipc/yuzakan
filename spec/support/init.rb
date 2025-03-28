# frozen_string_literal: true

# default let script

# action spec
def init_action_spec
  # response = subject.call(params)
  # expect(response).to be_...

  subject(:action) { described_class.new(**base_action_opts, **action_opts) }

  let_repo_mock
  let_structs

  let(:base_action_opts) do
    {
      config_repo: config_repo,
      network_repo: network_repo,
      user_repo: user_repo,
      action_log_repo: action_log_repo,
    }
  end

  # override let_repo_mock
  let(:config_repo_stubs) { {current: config} }
  let(:network_repo_stubs) { {find_include: network} }
  let(:user_repo_stubs) { {get: user} }
  let(:action_log_repo_stubs) { {create: action_log} }
  let(:action_log_repo_stubs) { {create: action_log} }
  let(:network) { Factory.structs[:network_trusted] }

  let(:params) { {**action_params, **env} }
  let(:env) do
    {
      "rack.session" => session,
      "REMOTE_ADDR" => client,
      "HTTP_ACCEPT" => format,
    }
  end
  let(:session) do
    {
      uuid: uuid,
      user: user.name,
      created_at: Time.now - 600,
      updated_at: Time.now - 60,
    }
  end
  let(:uuid) { "ffffffff-ffff-4fff-bfff-ffffffffffff" }
  let(:client) { "127.0.0.1" }
  let(:format) { "text/html" }

  # override if necessary for each action
  let(:action_opts) { {} }
  let(:action_params) { {} }
end

def init_operation_spec
  let_repo_mock
  let_structs
end

def let_repo_mock
  let(:config_repo) do
    instance_double(Yuzakan::Repos::ConfigRepo, **config_repo_stubs)
  end
  let(:network_repo) do
    instance_double(Yuzakan::Repos::NetworkRepo, **network_repo_stubs)
  end

  let(:affiliation_repo) do
    instance_double(Yuzakan::Repos::AffiliationRepo, **affiliation_repo_stubs)
  end
  let(:group_repo) do
    instance_double(Yuzakan::Repos::GroupRepo, **group_repo_stubs)
  end
  let(:user_repo) do
    instance_double(Yuzakan::Repos::UserRepo, **user_repo_stubs)
  end
  let(:member_repo) do
    instance_double(Yuzakan::Repos::MemberRepo, **member_repo_stubs)
  end

  let(:provider_repo) do
    instance_double(Yuzakan::Repos::ProviderRepo, **provider_repo_stubs)
  end

  let(:attr_repo) do
    instance_double(Yuzakan::Repos::AttrRepo, **attr_repo_stubs)
  end
  let(:attr_mapping_repo) do
    instance_double(Yuzakan::Repos::AttrMappingRepo, **attr_mapping_repo_stubs)
  end

  let(:action_log_repo) do
    instance_double(Yuzakan::Repos::ActionLogRepo, **action_log_repo_stubs)
  end
  let(:auth_log_repo) do
    instance_double(Yuzakan::Repos::AuthLogRepo, **auth_log_repo_stubs)
  end

  # repostitory stubs
  # let(:*_repo_stubs) {
  #   {
  #     create: struct,
  #     update: struct | nil,
  #     delete: struct | nil,
  #     all: sturt[],
  #     find: struct | nil,
  #     first: struct | nil,
  #     last: sturt | nil,
  #     clear: integer
  #     # and
  #     get: struct | nil
  #     set: sturct
  #     unset: struct | nil
  #     exist?: bool
  #     list: string[]
  #   }
  # }

  let(:config_repo_stubs) { {} }
  let(:network_repo_stubs) { {} }

  let(:affiliation_repo_stubs) { {} }
  let(:group_repo_stubs) { {} }
  let(:user_repo_stubs) { {} }
  let(:member_repo_stubs) { {} }

  let(:provider_repo_stubs) { {} }

  let(:attr_repo_stubs) { {} }
  let(:attr_mapping_repo_stubs) { {} }

  let(:action_log_repo_stubs) { {} }
  let(:auth_log_repo_stubs) { {} }
end

# TODO: あまり整理していないので、整理すること
def let_structs
  # single
  let(:config) { Factory.structs[:config] }
  let(:network) { Factory.structs[:network] }
  let(:affiliation) { Factory.structs[:affiliation] }
  let(:group) { Factory.structs[:group] }
  let(:user) { Factory.structs[:user] }
  let(:provider) { Factory.structs[:provider] }
  let(:attr) { Factory.structs[:attr] }
  let(:auth_log) { Factory.structs[:auth_log] }
  let(:action_log) { Factory.structs[:action_log] }

  # # multiple
  # let(:users) do
  #   users_attributes.map do |attributes|
  #     create_sturct(Yuzakan::Structs::User, Hanami.app["relations.users"],
  #       attributes)
  #   end
  # end

  # let(:providers) do
  #   providers_attributes.map do |attributes|
  #     create_sturct(Yuzakan::Structs::Provider,
  #       Hanami.app["relations.providers"],
  #       attributes)
  #   end
  # end

  # let(:attrs) do
  #   attrs_attributes.map do |attributes|
  #     create_sturct(Yuzakan::Structs::Attr, Hanami.app["relations.attrs"],
  #       attributes)
  #   end
  # end

  # single attributes
  # let(:config_attributes) do
  #   {title: "title", session_timeout: 3600, domain: "example.jp"}
  # end
  # let(:network_attributes) do
  #   {ip: IPAddr.new("127.0.0.0/8"), clearance_level: 5, trusted: true}
  # end

  # let(:user_attributes) do
  #   {
  #     id: 42, name: "user", display_name: "ユーザー", email: "user@example.jp",
  #     clearance_level: 1,
  #     prohibited: false, deleted: false, deleted_at: nil, note: nil,
  #   }
  # end
  # let(:group_attributes) { {id: 42, name: "group", display_name: "グループ"} }

  # let(:attr_attributes) do
  #   {
  #     id: 42, name: "attr42", display_name: "属性42", type: "string", order: 8,
  #     hidden: false, readonly: false, code: nil, description: nil,
  #   }
  # end
  # let(:action_log_attributes) do
  #   {uuid: uuid, client: client, user: user.name}
  # end

  # let(:provider_attriubtes) do
  #   {
  #     id: 42, name: "provider42", display_name: "プロバイダー42",
  #     adapter: "dummy", order: 8,
  #     readable: false, writable: false, authenticatable: false,
  #     password_changeable: false,
  #     lockable: false, group: false, individual_password: false,
  #     self_management: false,
  #     description: nil,
  #   }
  # end

  # # multiple attributse
  # let(:attrs_attributes) do
  #   [
  #     attr_attributes,
  #     {**attr_attributes, id: 19, name: "attr_bool", display_name: "真偽値属性",
  #                         type: "boolean", order: 24,},
  #     {**attr_attributes, id: 24, name: "attr_int", display_name: nil,
  #                         type: "整数属性", order: 16, code: '"hoge"',},
  #     {**attr_attributes, id: 27, name: "attr_str", display_name: "文字列属性",
  #                         type: "string", order: 64, hidden: true,},
  #     {**attr_attributes, id: 28, name: "attr_noname", display_name: nil,
  #                         type: "string", order: 32, readonly: true,},
  #   ]
  # end
  # let(:attr_mappings_attributes) do
  #   [
  #     {provider: "provider42", key: "map42", conversion: nil},
  #     {provider: "provider1", key: "path", conversion: "path"},
  #     {provider: "provider2", key: "e2j", conversion: "e2j"},
  #     {provider: "provider3", key: "j2e", conversion: "j2e"},
  #   ]
  # end
  # let(:networks_attributes) do
  #   [
  #     {address: "127.0.0.8/8", clearance_level: 5, trusted: true},
  #     {address: "10.0.0.0/8", clearance_level: 5, trusted: true},
  #     {address: "172.16.0.0/12", clearance_level: 5, trusted: true},
  #     {address: "192.168.0.0/16", clearance_level: 5, trusted: true},
  #     {address: "0.0.0.0/0", clearance_level: 1, trusted: false},
  #     {address: "::1", clearance_level: 5, trusted: true},
  #     {address: "fc00::/7", clearance_level: 5, trusted: true},
  #     {address: "::/0", clearance_level: 1, trusted: false},
  #     {address: "192.0.2.0/24", clearance_level: 1, trusted: true},
  #     {address: "198.51.100.0/24", clearance_level: 0, trusted: false},
  #     # {address: '203.0.113.0/24', clearance_level: 1, trusted: fales},
  #     {address: "2001:db8:1::/64", clearance_level: 1, trusted: true},
  #     {address: "2001:db8:2::/64", clearance_level: 1, trusted: false},
  #     # {address: '2001:db8::/32', clearance_level: 1, trusted: false},
  #     {address: "10.1.0.0/24", clearance_level: 0, trusted: true},
  #     {address: "10.1.1.0/24", clearance_level: 1, trusted: true},
  #     {address: "10.1.2.0/24", clearance_level: 2, trusted: true},
  #     {address: "10.1.3.0/24", clearance_level: 3, trusted: true},
  #     {address: "10.1.4.0/24", clearance_level: 4, trusted: true},
  #     {address: "10.1.5.0/24", clearance_level: 5, trusted: true},
  #     {address: "10.2.0.0/24", clearance_level: 0, trusted: false},
  #     {address: "10.2.1.0/24", clearance_level: 1, trusted: false},
  #     {address: "10.2.2.0/24", clearance_level: 2, trusted: false},
  #     {address: "10.2.3.0/24", clearance_level: 3, trusted: false},
  #     {address: "10.2.4.0/24", clearance_level: 4, trusted: false},
  #     {address: "10.2.5.0/24", clearance_level: 5, trusted: false},
  #   ]
  # end
  # let(:users_attributes) do
  #   [
  #     user_attributes,
  #     {**user_attributes, id: 1, name: "admin", display_name: "管理者",
  #                         email: "admin@example.jp", clearance_level: 5,},
  #     {**user_attributes, id: 24, name: "prohibited", prohibited: true},
  #     {**user_attributes, id: 19, name: "deleted", deleted: true,
  #                         deleted_at: Time.now - (24 * 60 * 60),},
  #   ]
  # end
  # let(:providers_attributes) do
  #   [
  #     provider_attriubtes,
  #     {**provider_attriubtes, id: 1, name: "provider1", display_name: "プロ1",
  #                             order: 8,},
  #     {**provider_attriubtes, id: 2, name: "provider2", display_name: "プロ2",
  #                             order: 32,},
  #     {**provider_attriubtes, id: 3, name: "provider3", display_name: nil,
  #                             order: 16,},
  #     {**provider_attriubtes, id: 4, name: "self_management_provider",
  #                             self_management: true,},
  #   ]
  # end
end
