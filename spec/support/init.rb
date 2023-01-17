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

# controller spec
def init_controller_spec(spec)
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
  spec.let(:client) { '192.0.2.1' }
  spec.let(:uuid) { 'ffffffff-ffff-4fff-bfff-ffffffffffff' }
  spec.let(:user) {
    User.new(id: 42, username: 'user', display_name: 'ユーザー', email: 'user@example.jp', clearance_level: 1)
  }
  spec.let(:session) { {uuid: uuid, user_id: user.id, created_at: Time.now - 600, updated_at: Time.now - 60} }
  spec.let(:format) { 'text/html' }
  spec.let(:config) { Config.new(title: 'title', session_timeout: 3600, domain: 'kyokyo-u.ac.jp') }
  spec.let(:networks) { [Network.new(address: '192.0.2.0/24', clearance_level: 5, trusted: true)] }
  spec.let(:activity_log_repository) {
    instance_double('ActivityLogRepository').tap { |obj| allow(obj).to receive(:create) } }
  spec.let(:config_repository) { instance_double('ConfigRepository', current: config) }
  spec.let(:network_repository) { instance_double('NetworkRepository', all: networks) }
  spec.let(:user_repository) { instance_double('UserRepository', find: user) }
end
