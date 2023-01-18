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

  let(:activity_log_repository_stubs) { {create: activity_log} }
  let(:config_repository_stubs) { {current: config} }
  let(:network_repository_stubs) { {all: networks} }
  let(:user_repository_stubs) {
    {
      find: user,
      find_by_username: user,
      update: user,
      find_with_groups: user_with_groups,
      set_primary_group: Member.new,
      add_group: Member.new,
      remove_group: Member.new,
    }
  }
  let(:group_repository_stubs) { {find_or_create_by_groupname: groups} }

  let(:activity_log) { ActivityLog.new(**activity_log_attributes) }
  let(:config) { Config.new(**config_attributes) }
  let(:network) { Network.new(**network_attributes) }
  let(:user) { User.new(**user_attributes) }
  let(:group) { Group.new(**group_attributes) }
  let(:user_with_groups) {
    User.new(**user_attributes,
      groups: [primary_group, *supplementary_groups].compact.uniq,
      members: [
        primary_group && Member.new(primary: true, group: primary_group),
        *supplementary_groups.reject { |g| g == primary_group }.map { |g| Memebr.new(primary: false, group: g) },
      ].comapct)
  }
  let(:networks) { [network] }
  let(:users) { [user] }
  let(:groups) { [group] }

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

  let(:activity_log_attributes) { {uuid: uuid, client: client, username: user.username} }
  let(:config_attributes) { {title: 'title', session_timeout: 3600, domain: 'example.jp'} }
  let(:network_attributes) { {address: '192.0.2.0/24', clearance_level: 1, trusted: true} }
  let(:user_attributes) {
    {
      id: 42, username: 'user', display_name: 'ユーザー', email: 'user@example.jp', clearance_level: 1,
      reserved: false, deleted: false, deleted_at: nil, note: nil,
    }
  }
  let(:group_attributes) { {id: 42, username: 'group', display_name: 'グループ'} }

  let(:uuid) { 'ffffffff-ffff-4fff-bfff-ffffffffffff' }
  let(:client) { '192.0.2.1' }
  let(:user_with_groups) { User.new(**user.to_h, members: [Member.new(primary: true, group: group)]) }
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
