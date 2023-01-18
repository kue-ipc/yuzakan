# frozen_string_literal: true

# default let script

def init_let_script
  <<~'LET_SCRIPT'
    let(:action_opts) {
      {
        activity_log_repository: activity_log_repository,
        config_repository: config_repository,
        network_repository: network_repository,
        user_repository: user_repository,
      }
    }
    let(:params) { {**action_params, **env} }
    let(:action_params) { {} }
    let(:env) { {'REMOTE_ADDR' => client, 'rack.session' => session, 'HTTP_ACCEPT' => format} }
    let(:client) { '192.0.2.1' }
    let(:uuid) { 'ffffffff-ffff-4fff-bfff-ffffffffffff' }
    let(:user) {
      User.new(id: 42, username: 'user', display_name: 'ユーザー', email: 'user@example.jp', clearance_level: 1)
    }
    let(:session) { {uuid: uuid, user_id: user.id, created_at: Time.now - 600, updated_at: Time.now - 60} }
    let(:format) { 'text/html' }
    let(:config) { Config.new(title: 'title', session_timeout: 3600, domain: 'kyokyo-u.ac.jp') }
    let(:networks) { [Network.new(address: '192.0.2.0/24', clearance_level: 5, trusted: true)] }
    let(:activity_log_repository) {
      instance_double('ActivityLogRepository').tap { |obj| allow(obj).to receive(:create) }
    }
    let(:config_repository) { instance_double('ConfigRepository', current: config) }
    let(:network_repository) { instance_double('NetworkRepository', all: networks) }
    let(:user_repository) { instance_double('UserRepository', find: user) }
  LET_SCRIPT
end

def let_mock_repositories(spec)
  spec.let(:activity_log_repository) { instance_double('ActivityLogRepository', create: activity_log) }
  spec.let(:config_repository) { instance_double('ConfigRepository', current: config) }
  spec.let(:network_repository) { instance_double('NetworkRepository', all: networks) }
  spec.let(:user_repository) {
    instance_double('UserRepository',
                    find: user,
                    find_by_username: user,
                    update: user,
                    find_with_groups: user_with_groups,
                    set_primary_group: Member.new,
                    add_group: Member.new,
                    remove_group: Member.new)
  }
  spec.let(:group_repository) {
    instance_double('GroupRepository',
                    find_or_create_by_groupname: groups)
  }

  spec.let(:activity_log) { ActivityLog.new(uuid: uuid, client: client, username: user.username) }
  spec.let(:uuid) { 'ffffffff-ffff-4fff-bfff-ffffffffffff' }
  spec.let(:client) { '192.0.2.1' }
  spec.let(:config) { Config.new(title: 'title', session_timeout: 3600, domain: 'kyokyo-u.ac.jp') }
  spec.let(:networks) { [Network.new(address: '192.0.2.0/24', clearance_level: 5, trusted: true)] }
  spec.let(:admin) {
    User.new(id: 1, username: 'admin', display_name: '管理者', email: 'admin@example.jp', clearance_level: 5,
             deleted: false,
             reserved: false,
             deleted_at: nil, note: nil)
  }
  spec.let(:user) {
    User.new(id: 42, username: 'user', display_name: 'ユーザー', email: 'user@example.jp', clearance_level: 1,
             deleted: false,
             deleted_at: nil, note: nil,
             reserved: false)
  }
  spec.let(:users) {
    [admin, user]
  }
  spec.let(:group) { Group.new(id: 42, username: 'group', display_name: 'グループ') }
  spec.let(:admin_group) { Group.new(id: 1, username: 'admin', display_name: '管理者') }
  spec.let(:staff_group) { Group.new(id: 10, username: 'staff', display_name: 'スタッフ') }

  spec.let(:groups) {
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
def init_controller_spec(spec)
  let_mock_repositories(spec)
  spec.let(:action_opts) {
    {
      activity_log_repository: activity_log_repository,
      config_repository: config_repository,
      network_repository: network_repository,
      user_repository: user_repository,
    }
  }
  spec.let(:params) { {**action_params, **env} }
  spec.let(:action_params) { {} }
  spec.let(:env) { {'REMOTE_ADDR' => client, 'rack.session' => session, 'HTTP_ACCEPT' => format} }
  # spec.let(:client) { '192.0.2.1' }
  # spec.let(:uuid) { 'ffffffff-ffff-4fff-bfff-ffffffffffff' }
  # spec.let(:user) {
  #   User.new(id: 42, username: 'user', display_name: 'ユーザー', email: 'user@example.jp', clearance_level: 1)
  # }
  spec.let(:session) { {uuid: uuid, user_id: user.id, created_at: Time.now - 600, updated_at: Time.now - 60} }
  spec.let(:format) { 'text/html' }
  # spec.let(:config) { Config.new(title: 'title', session_timeout: 3600, domain: 'kyokyo-u.ac.jp') }
  # spec.let(:networks) { [Network.new(address: '192.0.2.0/24', clearance_level: 5, trusted: true)] }
  # spec.let(:activity_log) { ActivityLog.new(uuid: uuid, client: client, username: user.username) }
  # spec.let(:activity_log_repository) { instance_double('ActivityLogRepository', create: activity_log) }
  # spec.let(:config_repository) { instance_double('ConfigRepository', current: config) }
  # spec.let(:network_repository) { instance_double('NetworkRepository', all: networks) }
  # spec.let(:user_repository) { instance_double('UserRepository', find: user) }
end

def init_intercactor_spec(spec)
  let_mock_repositories(spec)
end
