require_relative '../../../../spec_helper'

describe Api::Controllers::Adapters::ParamTypes::Index do
  let(:action) {
    Api::Controllers::Adapters::ParamTypes::Index.new(activity_log_repository: activity_log_repository,
                                                      config_repository: config_repository,
                                                      user_repository: user_repository)
  }
  let(:params) { {adapter_id: 'dummy', **env} }
  let(:env) { {'REMOTE_ADDR' => client, 'rack.session' => session, 'HTTP_ACCEPT' => format} }
  let(:client) { '192.0.2.1' }
  let(:uuid) { 'ffffffff-ffff-4fff-bfff-ffffffffffff' }
  let(:user) { User.new(id: 42, name: 'user', display_name: 'ユーザー', email: 'user@example.jp', clearance_level: 1) }
  let(:session) { {uuid: uuid, user_id: user.id, created_at: Time.now - 600, updated_at: Time.now - 60} }
  let(:format) { 'application/json' }
  let(:config) { Config.new(title: 'title', session_timeout: 3600, user_networks: '') }
  let(:activity_log_repository) { create_mock(create: [nil, [Hash]]) }
  let(:config_repository) { create_mock(current: [config]) }
  let(:user_repository) { create_mock(find: [user, [Integer]]) }

  it 'is failure' do
    response = action.call(params)
    _(response[0]).must_equal 403
    _(response[1]['Content-Type']).must_equal "#{format}; charset=utf-8"
    json = JSON.parse(response[2].first, symbolize_names: true)
    _(json).must_equal({code: 403, message: '許可されていません。'})
  end

  describe 'admin' do
    let(:user) { User.new(id: 1, name: 'admin', display_name: '管理者', email: 'admin@example.jp', clearance_level: 5) }

    it 'is successful' do
      response = action.call(params)
      _(response[0]).must_equal 200
      _(response[1]['Content-Type']).must_equal "#{format}; charset=utf-8"
      json = JSON.parse(response[2].first, symbolize_names: true)
      _(json).must_equal []
    end

    it 'is successful with test adapter' do
      response = action.call({**params, adapter_id: 'test'})
      _(response[0]).must_equal 200
      _(response[1]['Content-Type']).must_equal "#{format}; charset=utf-8"
      json = JSON.parse(response[2].first, symbolize_names: true)
      _(json).must_equal [
        {name: 'str', label: '文字列', description: '文字列の詳細です。', type: 'string', default: nil,
         list: nil, encrypted: false, input: 'text', placeholder: '', required: false,},
        {name: 'str_enc', label: '暗号文字列', description: '文字列のパラメーターです。', type: 'string', default: nil,
         list: nil, encrypted: true, input: 'text', placeholder: 'テスト', required: false,},
        {name: 'txt', label: '長い文字列', description: '文字列のパラメーターです。', type: 'text', default: nil,
         list: nil, encrypted: false, input: 'textarea', placeholder: '', required: false,},
        {name: 'int', label: '数値', description: '数値のパラメーターです。', type: 'integer', default: nil,
         list: nil, encrypted: false, input: 'number', placeholder: '', required: false,},
      ]
    end

    it 'is failure with unknown id' do
      response = action.call({**params, id: 'hoge'})
      _(response[0]).must_equal 404
      _(response[1]['Content-Type']).must_equal "#{format}; charset=utf-8"
      json = JSON.parse(response[2].first, symbolize_names: true)
      _(json).must_equal({code: 404, message: '該当のアダプターはありません。'})
    end
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
