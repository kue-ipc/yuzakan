# plese overwrite

def init_let_script
  -<<~'LET_SCRIPT'
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
    let(:activity_log_repository) { ActivityLogRepository.new.tap { |obj| stub(obj).create } }
    let(:config_repository) { ConfigRepository.new.tap { |obj| stub(obj).current { config } } }
    let(:network_repository) { NetworkRepository.new.tap { |obj| stub(obj).all { networks } } }
    let(:user_repository) { UserRepository.new.tap { |obj| stub(obj).find { user } } }
  LET_SCRIPT
end
