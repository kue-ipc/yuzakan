require_relative '../../../spec_helper'

describe Api::Controllers::Session::Create do
  let(:action) do
    Api::Controllers::Session::Create.new(activity_log_repository: activity_log_repository,
                                          config_repository: config_repository,
                                          user_repository: user_repository,
                                          provider_repository: provider_repository,
                                          auth_log_repository: auth_log_repository)
  end
  let(:params) { {session: {username: 'user', password: 'pass'}, 'REMOTE_ADDR' => '::1', 'rack.session' => session} }
  let(:session) { {uuid: 'x', user_id: 42, access_time: Time.now} }

  let(:activity_log_repository) { Minitest::Mock.new.expect(:create, nil, [Hash]) }

  let(:config) { Config.new(title: 'title', session_timeout: 3600, user_networks: '') }
  let(:config_repository) { Minitest::Mock.new.expect(:current, config) }

  let(:user) { User.new(name: 'user', display_name: 'ユーザー', email: 'user@example.jp') }
  let(:user_repository) do
    Minitest::Mock.new
      .expect(:find, user, [42])
      .expect(:find_by_name, user, ['user'])
      .expect(:update, nil, [42, {display_name: 'ユーザー', email: 'user@example.jp'}])
  end
  let(:providers) do
    [
      Minitest::Mock.new
        .expect(:auth, true, ['user', 'pass'])
        .expect(:read, {name: 'user', display_name: 'ユーザー', email: 'user@example.jp'}, ['user']),
    ]
  end
  let(:provider_repository) { Minitest::Mock.new.expect(:operational_all_with_adapter, providers, [:auth]) }
  let(:auth_log_repository) do
    Minitest::Mock.new
      .expect(:create, nil, [Hash])
      .expect(:recent_by_username, [], [String, Integer])
  end

  it 'is successful' do
    response = action.call(params)
    _(response[0]).must_equal 200
    _(response[2]).must_equal [JSON.generate({
      result: 'success',
      messages: {success: 'ログインしました。'},
      redirect_to: '/',
    })]
  end

  describe "no auth" do
    let(:providers) do
      [
        Minitest::Mock.new
          .expect(:auth, false, ['user', 'pass'])
          .expect(:read, {name: 'user', display_name: 'ユーザー', email: 'user@example.jp'}, ['user']),
      ]
    end

    it 'is failed' do
      response = action.call(params)
      _(response[0]).must_equal 422
      _(response[2]).must_equal [JSON.generate({
        result: 'failure',
        messages: {
          errors: ['ユーザー名またはパスワードが違います。'],
          failure: 'ログインに失敗しました。',
        },
      })]
    end
  end

  it 'is error' do
    response = action.call(**params, session: nil)
    _(response[0]).must_equal 400
    _(response[2]).must_equal ['Bad Request']
  end

  it 'is error' do
    response = action.call(**params, session: {username: 'user'})
    _(response[0]).must_equal 400
    _(response[2]).must_equal ['Bad Request']
  end
end
