require_relative '../../../spec_helper'

describe Api::Controllers::CurrentUser::Show do
  let(:action) {
    Api::Controllers::CurrentUser::Show.new(activity_log_repository: activity_log_repository,
                                            config_repository: config_repository,
                                            user_repository: user_repository,
                                            provider_repository: provider_repository)
  }
  let(:params) { {session: {username: 'user', password: 'pass'}, **env} }
  let(:env) { {'REMOTE_ADDR' => remote_ip, 'rack.session' => session, 'HTTP_ACCEPT' => format} }
  let(:remote_ip) { '192.0.2.1' }
  let(:uuid) { 'ffffffff-ffff-4fff-bfff-ffffffffffff' }
  let(:user) {
    User.new(id: 42, name: 'user', display_name: 'ユーザー', email: 'user@example.jp', admin: false,
             created_at: Time.now - 86400, updated_at: Time.now - 3600)
  }
  let(:session) { {uuid: uuid, user_id: user.id, created_at: Time.now - 600, updated_at: Time.now - 60} }
  let(:format) { 'application/json' }
  let(:config) { Config.new(title: 'title', session_timeout: 3600, user_networks: '') }
  let(:activity_log_repository) { create_mock(create: [nil, [Hash]]) }
  let(:config_repository) { create_mock(current: [config]) }
  let(:user_repository) { create_mock(find: [user, [Integer]]) }

  let(:providers) { [create_mock_provider(name: 'provider', params: {username: 'user', password: 'pass'})] }
  let(:provider_repository) { create_mock(operational_all_with_adapter: [providers, [Symbol]]) }

  it 'is successful' do
    response = action.call(params)
    _(response[0]).must_equal 200
    _(response[1]['Content-Type']).must_equal "#{format}; charset=utf-8"
    json = JSON.parse(response[2].first, symbolize_names: true)
    _(json).must_equal({
      name: 'user',
      display_name: 'ユーザー',
      email: 'user@example.jp',
      clearance_level: 2,
      created_at: user.created_at.floor.iso8601,
      updated_at: user.updated_at.floor.iso8601,
      userdata: {
        name: 'user',
        display_name: 'ユーザー',
        email: 'user@example.jp',
        attrs: {},
        count: 1,
      },
      providers: ['provider'],
    })
  end
end
