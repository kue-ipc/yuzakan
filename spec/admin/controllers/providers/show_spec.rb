require_relative '../../../spec_helper'

describe Admin::Controllers::Providers::Show do
  let(:action) {
    Admin::Controllers::Providers::Show.new(activity_log_repository: activity_log_repository,
                                            config_repository: config_repository,
                                            user_repository: user_repository,
                                            provider_repository: provider_repository)
  }
  let(:params) { {**env, id: 'provider1'} }

  let(:env) { {'REMOTE_ADDR' => client, 'rack.session' => session, 'HTTP_ACCEPT' => format} }
  let(:client) { '192.0.2.1' }
  let(:uuid) { 'ffffffff-ffff-4fff-bfff-ffffffffffff' }
  let(:user) { User.new(id: 42, name: 'user', display_name: 'ユーザー', email: 'user@example.jp', clearance_level: 1) }
  let(:session) { {uuid: uuid, user_id: user.id, created_at: Time.now - 600, updated_at: Time.now - 60} }
  let(:format) { 'text/html' }
  let(:config) { Config.new(title: 'title', session_timeout: 3600) }
  let(:activity_log_repository) { ActivityLogRepository.new.tap { |obj| stub(obj).create } }
  let(:config_repository) { ConfigRepository.new.tap { |obj| stub(obj).current { config } } }
  let(:user_repository) { UserRepository.new.tap { |obj| stub(obj).find { user } } }

  let(:provider_repository) {
    ProviderRepository.new.tap { |obj| stub(obj).exist_by_name?('provider1') { true } }
  }

  it 'is failure' do
    response = action.call(params)
    _(response[0]).must_equal 403
  end

  describe 'admin' do
    let(:user) { User.new(id: 1, name: 'admin', display_name: '管理者', email: 'admin@example.jp', clearance_level: 5) }

    it 'is successful' do
      response = action.call(params)
      _(response[0]).must_equal 200
    end

    it 'is successful with * for new' do
      response = action.call({**params, id: '*'})
      _(response[0]).must_equal 200
    end

    it 'is failure with !' do
      response = action.call({**params, id: '!'})
      _(response[0]).must_equal 400
    end

    describe 'not existed' do
      let(:provider_repository) {
        ProviderRepository.new.tap { |obj| mock(obj).exist_by_name?('provider1') { false } }
      }

      it 'is failure' do
        response = action.call(params)
        _(response[0]).must_equal 404
      end
    end
  end

  describe 'redirect no login session' do
    let(:session) { {uuid: uuid} }

    it 'is error' do
      response = action.call(params)
      _(response[0]).must_equal 302
      _(response[1]['Location']).must_equal '/'
    end
  end
end
