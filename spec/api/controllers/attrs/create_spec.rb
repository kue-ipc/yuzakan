require_relative '../../../spec_helper'

describe Api::Controllers::Attrs::Create do
  let(:action) {
    Api::Controllers::Attrs::Create.new(activity_log_repository: activity_log_repository,
                                        config_repository: config_repository,
                                        user_repository: user_repository,
                                        attr_repository: attr_repository,
                                        attr_mapping_repository: attr_mapping_repository)
  }
  let(:params) { {**env, **attr_params} }
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

  let(:attr_params) { {name: 'name', display_name: '表示名', type: 'string'} }

  let(:created_time) { Time.now }
  let(:last_attr) { Attr.new(order: 6) }
  let(:created_attr) {
    Attr.new(id: 42, **attr_params, order: 7, hidden: false, created_at: created_time, updated_at: created_time)
  }
  let(:attr_repository) { create_mock(last_order: [last_attr], create: [created_attr, [Hash]]) }
  let(:attr_mapping_repository) { create_mock(create: [AttrMapping.new, [Hash]]) }

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
      _(response[0]).must_equal 201
      _(response[1]['Content-Type']).must_equal "#{format}; charset=utf-8"
      json = JSON.parse(response[2].first, symbolize_names: true)
      _(json).must_equal({
        id: 42,
        name: 'name',
        display_name: '表示名',
        type: 'string',
        order: 43,
        hidden: true,
        created_at: created_time.iso8601,
        updated_at: created_time.iso8601,
      })
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
