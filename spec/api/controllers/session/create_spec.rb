require_relative '../../../spec_helper'

describe Api::Controllers::Session::Create do
  let(:action) do
    Api::Controllers::Session::Create.new(
      activity_log_repository: activity_log_repository,
      config_repository: config_repository,
      user_repository: user_repository,
      provider_repository: provider_repository,
      auth_log_repository: auth_log_repository)
  end
  let(:params) { {username: 'user', password: 'pass', 'REMOTE_ADDR' => '::1', 'rack.session' => session} }
  let(:session) { {uuid: 'xx', user_id: 1, access_time: Time.now} }
  let(:activity_log_repository) { double('activity_log_repository', create: nil) }
  let(:config) { Config.new(title: 'title', session_timeout: 3600, user_networks: '') }
  let(:user_repository) { double('user_repository', find: user) }
  let(:config_repository) { double('config_repository', current: config) }
  let(:provider_repository) { double('provider_repository') }
  let(:auth_log_repository) { double('auth_log_repository', create: nil) }

  it 'is successful' do
    response = action.call(params)
    _(response[0]).must_equal 200
  end
end
