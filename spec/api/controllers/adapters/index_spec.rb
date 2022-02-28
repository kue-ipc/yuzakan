require_relative '../../../spec_helper'

describe Api::Controllers::Adapters::Index do
  let(:action) {
    Api::Controllers::Adapters::Index.new(activity_log_repository: activity_log_repository,
                                          config_repository: config_repository,
                                          user_repository: user_repository)
  }
  let(:params) { env }
  let(:env) { {'REMOTE_ADDR' => client, 'rack.session' => session, 'HTTP_ACCEPT' => format} }
  let(:client) { '192.0.2.1' }
  let(:uuid) { 'ffffffff-ffff-4fff-bfff-ffffffffffff' }
  let(:user) { User.new(id: 42, name: 'user', display_name: 'ユーザー', email: 'user@example.jp', clearance_level: 1) }
  let(:session) { {uuid: uuid, user_id: user.id, created_at: Time.now - 600, updated_at: Time.now - 60} }
  let(:format) { 'application/json' }
  let(:config) { Config.new(title: 'title', session_timeout: 3600, user_networks: '') }
  let(:activity_log_repository) { create_mock(create: [nil, [Hash]]) }
  let(:config_repository) { create_mock(current: config) }
  let(:user_repository) { create_mock(find: [user, [Integer]]) }

  it 'is successful' do
    response = action.call(params)
    _(response[0]).must_equal 200
    _(response[1]['Content-Type']).must_equal "#{format}; charset=utf-8"
    json = JSON.parse(response[2].first, symbolize_names: true)
    _(json).must_equal [
      {name: 'ad',          label: 'Active Directory'},
      {name: 'dummy',       label: 'ダミー'},
      {name: 'google',      label: 'Google Workspace'},
      {name: 'local',       label: 'ローカル'},
      {name: 'mock',        label: 'モック'},
      {name: 'person_ldap', label: 'Person LDAP'},
      {name: 'posix_ldap',  label: 'Posix LDAP'},
      {name: 'samba_ldap',  label: 'Samba LDAP'},
      {name: 'test',        label: 'テスト'},
    ]
  end

  describe 'no login session' do
    let(:session) { {uuid: uuid} }

    it 'is error' do
      response = action.call(params)
      _(response[0]).must_equal 401
      _(response[1]['Content-Type']).must_equal "#{format}; charset=utf-8"
      json = JSON.parse(response[2].first, symbolize_names: true)
      _(json).must_equal({code: 401, message: 'ログインしてください。'})
    end
  end
end
