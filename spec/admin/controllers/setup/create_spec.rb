require_relative '../../../spec_helper'

describe Admin::Controllers::Setup::Create do
  let(:action) {
    Admin::Controllers::Setup::Create.new(activity_log_repository: activity_log_repository,
                                          config_repository: config_repository,
                                          user_repository: user_repository)
  }
  let(:params) {
    {
      **env,
      setup: {
        config: {title: 'テスト'},
        admin_user: {username: 'admin', password: 'pass', password_confirmation: 'pass'},
      },
    }
  }

  let(:env) { {'REMOTE_ADDR' => client, 'rack.session' => session, 'HTTP_ACCEPT' => format} }
  let(:client) { '192.0.2.1' }
  let(:uuid) { 'ffffffff-ffff-4fff-bfff-ffffffffffff' }
  let(:user) { User.new(id: 42, name: 'user', display_name: 'ユーザー', email: 'user@example.jp', clearance_level: 1) }
  let(:session) { {uuid: uuid, user_id: user.id, created_at: Time.now - 600, updated_at: Time.now - 60} }
  let(:format) { 'application/json' }
  let(:config) { Config.new(title: 'title', session_timeout: 3600) }
  let(:activity_log_repository) { ActivityLogRepository.new.tap { |obj| stub(obj).create } }
  let(:config_repository) { ConfigRepository.new.tap { |obj| stub(obj).current { config } } }
  let(:user_repository) { UserRepository.new.tap { |obj| stub(obj).find { user } } }

  it 'rediret to setup' do
    response = action.call(params)
    _(response[0]).must_equal 302
    _(response[1]['Location']).must_equal '/admin/setup'
  end

  # describe 'before initialized' do
  #   let(:config_repository) { ConfigRepository.new.tap { |obj| stub(obj).current { nil } } }

  #   it 'is successful' do
  #     response = action.call(params)
  #     _(response[0]).must_equal 200
  #   end
  # end
end
