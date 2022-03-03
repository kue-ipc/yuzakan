require_relative '../../../spec_helper'

describe Api::Controllers::Attrs::Show do
  let(:action) {
    Api::Controllers::Attrs::Show.new(activity_log_repository: activity_log_repository,
                                      config_repository: config_repository,
                                      user_repository: user_repository,
                                      attr_repository: attr_repository)
  }
  let(:params) { {**env, id: 42} }
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

  let(:attr_params) {
    {
      name: 'name', label: '表示名', type: 'string', hidden: false,
      attr_mappings: [
        {name: 'name', conversion: nil, provider_id: 3},
        {name: 'name_name', conversion: 'e2j', provider_id: 8},
      ],
    }
  }

  let(:attr_with_mappings) { Attr.new(id: 42, order: 7, **attr_params) }
  let(:attr_repository) { create_mock(find_with_mappings: [attr_with_mappings, [Integer]]) }

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
      _(json).must_equal({id: 42, order: 7, **attr_params})
    end

    describe 'not existed' do
      let(:attr_repository) { create_mock(find_with_mappings: [nil, [Integer]]) }

      it 'is failure' do
        response = action.call(params)
        _(response[0]).must_equal 404
        _(response[1]['Content-Type']).must_equal "#{format}; charset=utf-8"
        json = JSON.parse(response[2].first, symbolize_names: true)
        _(json).must_equal({
          code: 404,
          message: 'Not Found',
        })
      end
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
