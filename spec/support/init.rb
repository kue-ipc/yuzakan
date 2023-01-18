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

  let(:activity_log) { ActivityLog.new(uuid: uuid, client: client, username: user.username) }
  let(:uuid) { 'ffffffff-ffff-4fff-bfff-ffffffffffff' }
  let(:client) { '192.0.2.1' }
  let(:config) { Config.new(title: 'title', session_timeout: 3600, domain: 'kyokyo-u.ac.jp') }
  let(:networks) { [Network.new(address: '192.0.2.0/24', clearance_level: 5, trusted: true)] }
  let(:admin) {
    User.new(id: 1, username: 'admin', display_name: '管理者', email: 'admin@example.jp', clearance_level: 5,
             deleted: false,
             reserved: false,
             deleted_at: nil, note: nil)
  }
  let(:user) {
    User.new(id: 42, username: 'user', display_name: 'ユーザー', email: 'user@example.jp', clearance_level: 1,
             deleted: false,
             deleted_at: nil, note: nil,
             reserved: false)
  }
  let(:users) {
    [admin, user]
  }
  let(:group) { Group.new(id: 42, username: 'group', display_name: 'グループ') }
  let(:admin_group) { Group.new(id: 1, username: 'admin', display_name: '管理者') }
  let(:staff_group) { Group.new(id: 10, username: 'staff', display_name: 'スタッフ') }

  let(:groups) {
    [admin_group, group, staff_group]
  }
  let(:user_with_groups) {
    User.new(**user.to_h,
      members: [
        Member.new(primary: true, group: group),
        Member.new(primary: false, group: admin_group),
        Member.new(primary: false, group: staff_group),
      ])
  }
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
