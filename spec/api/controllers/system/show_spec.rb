require_relative '../../../spec_helper'

describe Api::Controllers::System::Show do
  let(:action) {
    Api::Controllers::System::Show.new(activity_log_repository: activity_log_repository,
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
  let(:config) { Config.new(title: 'title', session_timeout: 3600) }
  let(:activity_log_repository) { ActivityLogRepository.new.tap { |obj| stub(obj).create } }
  let(:config_repository) { ConfigRepository.new.tap { |obj| stub(obj).current { config } } }
  let(:user_repository) { UserRepository.new.tap { |obj| stub(obj).find { user } } }

  it 'is successful' do
    response = action.call(params)
    _(response[0]).must_equal 200
    _(response[1]['Content-Type']).must_equal "#{format}; charset=utf-8"
    json = JSON.parse(response[2].first, symbolize_names: true)
    _(json).must_equal({
      url: 'http://0.0.0.0:2300/',
      title: 'title',
      contact: {name: nil, email: nil, phone: nil},
      app: {name: 'Yuzakan', version: '0.6.0',
            license: File.read(File.join(__dir__, '../../../../LICENSE')),},
    })
  end

  describe 'other config' do
    let(:config) {
      Config.new(title: 'title2', session_timeout: 3600, contact_name: 'admin', contact_email: 'admin@examle.jp',
                 contact_phone: '00-0000-0000')
    }

    it 'is successful' do
      response = action.call(params)
      _(response[0]).must_equal 200
      _(response[1]['Content-Type']).must_equal "#{format}; charset=utf-8"
      json = JSON.parse(response[2].first, symbolize_names: true)
      _(json).must_equal({
        url: 'http://0.0.0.0:2300/',
        title: 'title2',
        contact: {name: 'admin', email: 'admin@examle.jp', phone: '00-0000-0000'},
        app: {name: 'Yuzakan', version: '0.6.0',
              license: File.read(File.join(__dir__, '../../../../LICENSE')),},
      })
    end
  end

  describe 'no login session' do
    let(:session) { {uuid: uuid} }

    it 'is successful' do
      response = action.call(params)
      _(response[0]).must_equal 200
      _(response[1]['Content-Type']).must_equal "#{format}; charset=utf-8"
      json = JSON.parse(response[2].first, symbolize_names: true)
      _(json).must_equal({
        url: 'http://0.0.0.0:2300/',
        title: 'title',
        contact: {name: nil, email: nil, phone: nil},
        app: {name: 'Yuzakan', version: '0.6.0',
              license: File.read(File.join(__dir__, '../../../../LICENSE')),},
      })
    end
  end
end
