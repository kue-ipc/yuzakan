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
  let(:activity_log_repository) { ActivityLogRepository.new.tap { |obj| stub(obj).create } }
  let(:config_repository) { ConfigRepository.new.tap { |obj| stub(obj).current { config } } }
  let(:user_repository) { UserRepository.new.tap { |obj| stub(obj).find { user } } }

  it 'is failure' do
    response = action.call(params)
    _(response[0]).must_equal 403
    _(response[1]['Content-Type']).must_equal "#{format}; charset=utf-8"
    json = JSON.parse(response[2].first, symbolize_names: true)
    _(json).must_equal({code: 403, message: 'Forbidden'})
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
        {name: 'default', label: 'default', description: nil,
         type: 'string', default: nil, fixed: false, encrypted: false,
         input: 'text', list: nil, required: true, placeholder: nil,},
        {name: 'str', label: '文字列', description: '詳細',
         type: 'string', default: nil, fixed: false, encrypted: false,
         input: 'text', list: nil, required: true, placeholder: 'プレースホルダー',},
        {name: 'str', label: 'デフォルト値', description: nil,
         type: 'string', default: 'デフォルト', fixed: false, encrypted: false,
         input: 'text', list: nil, required: false, placeholder: 'デフォルト',},
        {name: 'fixed', label: '固定値', description: nil,
         type: 'string', default: '固定', fixed: true, encrypted: false,
         input: 'text', list: nil, required: false, placeholder: '固定',},
        {name: 'required', label: '必須文字列', description: nil,
         type: 'string', default: nil, fixed: false, encrypted: false,
         input: 'text', list: nil, required: true, placeholder: nil,},
        {name: 'str_enc', label: '暗号文字列', description: nil,
         type: 'string', default: nil, fixed: false, encrypted: true,
         input: 'text', list: nil, required: true, placeholder: nil,},
        {name: 'txt', label: 'テキスト', description: nil,
         type: 'text', default: nil, fixed: false, encrypted: false,
         input: 'textarea', list: nil, required: true, placeholder: nil,},
        {name: 'int', label: '整数', description: nil,
         type: 'integer', default: nil, fixed: false, encrypted: false,
         input: 'number', list: nil, required: true, placeholder: nil,},
        {name: 'list', label: 'リスト', description: nil,
         type: 'string', default: 'default', fixed: false, encrypted: false,
         input: 'text', list: [
           {name: 'cleartext', label: 'デフォルト', value: 'default', deprecated: false},
           {name: 'cleartext', label: 'その他', value: 'other', deprecated: false},
           {name: 'cleartext', label: '非推奨', value: 'deprecated', deprecated: true},
         ], required: false, placeholder: 'default',},
      ]
    end

    it 'is failure with unknown id' do
      response = action.call({**params, adapter_id: 'hoge'})
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
      _(json).must_equal({code: 401, message: 'Unauthorized'})
    end
  end
end
