# frozen_string_literal: true

# default let script

def let_mock_repositories
  let(:activity_log_repository) { instance_double('ActivityLogRepository', **activity_log_repository_stubs) }
  let(:attr_mapping_repository) { instance_double('AttrMappingRepository', **attr_mapping_repository_stubs) }
  let(:attr_repository) { instance_double('AttrRepository', **attr_repository_stubs) }
  let(:auth_log_repository) { instance_double('AuthLogRepository', **auth_log_repository_stubs) }
  let(:config_repository) { instance_double('CnofigRepository', **config_repository_stubs) }
  let(:group_repository) { instance_double('GroupRepository', **group_repository_stubs) }
  let(:member_repository) { instance_double('MemberRepository', **member_repository_stubs) }
  let(:network_repository) { instance_double('NetworkRepository', **network_repository_stubs) }
  let(:provider_param_repository) { instance_double('ProviderParamRepository', **provider_param_repository_stubs) }
  let(:provider_repository) { instance_double('ProviderRepository', **provider_repository_stubs) }
  let(:user_repository) { instance_double('UserRepository', **user_repository_stubs) }

  # repostitory stubs
  # let(:model_repository_stubs) {
  #   {
  #     create: model,
  #     update: model || nil,
  #     delete: model || nil,
  #     all: models,
  #     find: model || nil,
  #     last: model || nil,
  #     clear: models.size,
  #   }
  # }
  let(:activity_log_repository_stubs) { {create: activity_log} }
  let(:attr_mapping_repository_stubs) { {} }
  let(:attr_repository_stubs) {
    {
      update: attr,
      delete: attr,
      ordered_all: attrs.sort_by(&:name).sort_by(&:order),
      find_with_mappings_by_name: attr_with_mappings,
      find_with_mappings: attr_with_mappings,
      exist_by_name?: false,
      last_order: 42,
      create_with_mappings: attr_with_mappings,
      add_mapping: attr_mappings.first,
    }
  }
  let(:auth_log_repository_stubs) { {} }
  let(:config_repository_stubs) { {current: config} }
  let(:group_repository_stubs) { {find_or_create_by_groupname: groups} }
  let(:member_repository_stubs) { {} }
  let(:network_repository_stubs) { {all: networks} }
  let(:provider_param_repository_stubs) { {} }
  let(:provider_repository_stubs) {
    {
      all: providers,
    }
  }
  let(:user_repository_stubs) {
    {
      update: user,
      find: user,
      find_by_username: user,
      find_with_groups: user_with_groups,
      set_primary_group: Member.new,
      add_group: Member.new,
      remove_group: Member.new,
    }
  }

  let(:activity_log) { ActivityLog.new(**activity_log_attributes) }
  let(:attr) { Attr.new(**attr_attributes) }
  let(:config) { Config.new(**config_attributes) }
  # let(:network) { Network.new(**network_attributes) }
  let(:user) { User.new(**user_attributes) }
  let(:group) { Group.new(**group_attributes) }

  let(:attrs) { attrs_attributes.map { |attributes| Attr.new(attributes) } }
  let(:networks) { networks_attributes.map { |attributes| Network.new(attributes) } }
  let(:users) { users_attributes.map { |attributes| User.new(attributes) } }
  let(:groups) { [group] }
  let(:providers) { providers_attributes.map { |attributes| Provider.new(attributes) } }

  let(:attr_with_mappings) { Attr.new(**attr_attributes, attr_mappings: attr_mappings) }
  let(:user_with_groups) { User.new(**user_attributes, groups: user_members.map(&:group), members: user_members) }

  let(:attr_mappings) {
    attr_mappings_attributes.map do |attributes|
      AttrMapping.new(provider: Provider.new(name: attributes[:provider]), **attributes.except(:provider))
    end
  }
  let(:user_members) {
    [
      primary_group && Member.new(primary: true, group: primary_group),
      *supplementary_groups
        .reject { |g| g.groupname == primary_group.groupname }
        .map { |g| Memebr.new(primary: false, group: g) },
    ].compact
  }
  let(:primary_group) { group }
  let(:supplementary_groups) { [] }

  # single attributes
  let(:attr_attributes) {
    {
      id: 42, name: 'attr42', display_name: '属性42', type: 'string', order: 8,
      hidden: false, readonly: false, code: nil, description: nil,
    }
  }
  let(:activity_log_attributes) { {uuid: uuid, client: client, username: user.username} }
  let(:config_attributes) { {title: 'title', session_timeout: 3600, domain: 'example.jp'} }
  let(:user_attributes) {
    {
      id: 42, username: 'user', display_name: 'ユーザー', email: 'user@example.jp', clearance_level: 1,
      reserved: false, deleted: false, deleted_at: nil, note: nil,
    }
  }
  let(:group_attributes) { {id: 42, username: 'group', display_name: 'グループ'} }
  let(:provider_attriubtes) {
    {
      id: 42, name: 'provider42', display_name: 'プロバイダー42', adapter_name: 'dummy', order: 8,
      readable: false, writable: false, authenticatable: false, password_changeable: false,
      lockable: false, group: false, individual_password: false, self_management: false,
      description: nil,
    }
  }

  # multiple attributse
  let(:attrs_attributes) {
    [
      attr_attributes,
      {**attr_attributes, id: 19, name: 'attr19', display_name: '属性19', type: 'boolean', order: 24},
      {**attr_attributes, id: 24, name: 'attr24', display_name: nil, type: 'integer', order: 16, code: '"hoge"'},
      {**attr_attributes, id: 27, name: 'attr27', display_name: '属性27', type: 'string', order: 64, hidden: true},
      {**attr_attributes, id: 28, name: 'attr28', display_name: nil, type: 'string', order: 32, readonly: true},
    ]
  }
  let(:attr_mappings_attributes) {
    [
      {provider: 'provider42', name: 'map42', conversion: nil},
      {provider: 'provider1', name: 'path', conversion: 'path'},
      {provider: 'provider2', name: 'e2j', conversion: 'e2j'},
      {provider: 'provider3', name: 'j2e', conversion: 'j2e'},
    ]
  }
  let(:networks_attributes) {
    [
      {address: '127.0.0.8/8', clearance_level: 5, trusted: true},
      {address: '10.0.0.0/8', clearance_level: 5, trusted: true},
      {address: '172.16.0.0/12', clearance_level: 5, trusted: true},
      {address: '192.168.0.0/16', clearance_level: 5, trusted: true},
      {address: '0.0.0.0/0', clearance_level: 1, trusted: false},
      {address: '::1', clearance_level: 5, trusted: true},
      {address: 'fc00::/7', clearance_level: 5, trusted: true},
      {address: '::/0', clearance_level: 1, trusted: false},
      {address: '192.0.2.0/24', clearance_level: 1, trusted: true},
      {address: '198.51.100.0/24', clearance_level: 0, trusted: false},
      # {address: '203.0.113.0/24', clearance_level: 1, trusted: fales},
      {address: '2001:db8:1::/64', clearance_level: 1, trusted: true},
      {address: '2001:db8:2::/64', clearance_level: 1, trusted: false},
      # {address: '2001:db8::/32', clearance_level: 1, trusted: false},
      {address: '10.1.0.0/24', clearance_level: 0, trusted: true},
      {address: '10.1.1.0/24', clearance_level: 1, trusted: true},
      {address: '10.1.2.0/24', clearance_level: 2, trusted: true},
      {address: '10.1.3.0/24', clearance_level: 3, trusted: true},
      {address: '10.1.4.0/24', clearance_level: 4, trusted: true},
      {address: '10.1.5.0/24', clearance_level: 5, trusted: true},
      {address: '10.2.0.0/24', clearance_level: 0, trusted: false},
      {address: '10.2.1.0/24', clearance_level: 1, trusted: false},
      {address: '10.2.2.0/24', clearance_level: 2, trusted: false},
      {address: '10.2.3.0/24', clearance_level: 3, trusted: false},
      {address: '10.2.4.0/24', clearance_level: 4, trusted: false},
      {address: '10.2.5.0/24', clearance_level: 5, trusted: false},
    ]
  }
  let(:users_attributes) {
    [
      user_attributes,
      {**user_attributes, id: 1, username: 'admin', display_name: '管理者', email: 'admin@example.jp', clearance_level: 5},
      {**user_attributes, id: 24, username: 'reserved', reserved: true},
      {**user_attributes, id: 19, username: 'deleted', deleted: true, deleted_at: Time.now - (24 * 60 * 60)},
    ]
  }
  let(:providers_attributes) {
    [
      provider_attriubtes,
      {**provider_attriubtes, id: 1, name: 'provider1', display_name: 'プロ1', order: 8},
      {**provider_attriubtes, id: 2, name: 'provider2', display_name: 'プロ2', order: 32},
      {**provider_attriubtes, id: 3, name: 'provider3', display_name: nil, order: 16},
      {**provider_attriubtes, id: 4, name: 'self_management_provider', self_management: true},
    ]
  }

  let(:uuid) { 'ffffffff-ffff-4fff-bfff-ffffffffffff' }
  let(:client) { '192.0.2.1' }
end

# controller spec
def init_controller_spec
  let_mock_repositories
  let(:action) { described_class.new(**connection_opts, **action_opts) }
  let(:connection_opts) {
    {
      activity_log_repository: activity_log_repository,
      config_repository: config_repository,
      network_repository: network_repository,
      user_repository: user_repository,
    }
  }
  let(:params) { {**action_params, **env} }
  let(:env) { {'REMOTE_ADDR' => client, 'rack.session' => session, 'HTTP_ACCEPT' => format} }
  let(:session) { {uuid: uuid, user_id: user.id, created_at: Time.now - 600, updated_at: Time.now - 60} }
  let(:format) { 'text/html' }
  # overwrite
  let(:action_opts) { {} }
  let(:action_params) { {} }
  # response = action.call({**params, ...})
end

def init_intercactor_spec
  let_mock_repositories
end
