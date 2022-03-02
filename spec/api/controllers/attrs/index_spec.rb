require_relative '../../../spec_helper'

describe Api::Controllers::Attrs::Index do
  let(:action) {
    Api::Controllers::Attrs::Index.new(activity_log_repository: activity_log_repository,
                                       config_repository: config_repository,
                                       user_repository: user_repository,
                                       attr_repository: attr_repository)
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

  let(:attr_params) { {name: 'name', label: '表示名', type: 'string'} }

  let(:time) { Time.now - 3600 }
  let(:all_attr) {
    [
      Attr.new(id: 42, name: 'name42', label: 'ラベル42', type: 'string', order: 1, hidden: false),
      Attr.new(id: 24, name: 'name24', label: 'ラベル24', type: 'string', order: 2, hidden: false),
      Attr.new(id: 19, name: 'name19', label: 'ラベル19', type: 'string', order: 3, hidden: false),
      Attr.new(id: 27, name: 'name27', label: 'ラベル27', type: 'string', order: 4, hidden: false),
    ]
  }
  let(:attr_repository) { create_mock(ordered_all: all_attr) }

  it 'is successful' do
    response = action.call(params)
    _(response[0]).must_equal 200
    _(response[1]['Content-Type']).must_equal "#{format}; charset=utf-8"
    json = JSON.parse(response[2].first, symbolize_names: true)
    _(json).must_equal [
      {id: 42, name: 'name42', label: '表示名42', type: 'string', order: 1, hidden: false},
      {id: 24, name: 'name24', label: '表示名24', type: 'string', order: 2, hidden: false},
      {id: 19, name: 'name19', label: '表示名19', type: 'string', order: 3, hidden: false},
      {id: 27, name: 'name27', label: '表示名27', type: 'string', order: 4, hidden: false},
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
