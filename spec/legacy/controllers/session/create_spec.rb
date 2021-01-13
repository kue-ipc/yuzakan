require_relative '../../../spec_helper'

describe Legacy::Controllers::Session::Create do
  let(:action) { Legacy::Controllers::Session::Create.new }
  let(:params) { {'REMOTE_ADDR' => '::1', 'rack.session' => session} }
  let(:session) { {user_id: user_id, access_time: Time.now} }
  let(:user_id) { Authenticate.new(client: '::1').call(auth).user&.id }
  let(:auth) { {username: 'user', password: 'word'} }

  it 'already login' do
    response = action.call(params)
    flash = action.exposures[:flash]
    _(response[0]).must_equal 302
    _(response[1]['Location']).must_equal '/legacy/dashboard'
    _(flash[:info]).must_equal '既にログインしています。'
  end

  describe 'no user_id' do
    let(:session) { {access_time: Time.now} }

    it 'login successful' do
      response = action.call(params.merge({session: auth}))
      flash = action.exposures[:flash]
      _(response[0]).must_equal 302
      _(response[1]['Location']).must_equal '/legacy/dashboard'
      _(flash[:success]).must_equal 'ログインしました。'
    end

    it 'loguin failure' do
      response = action.call(params.merge({
        session: {username: 'user', password: 'pass'},
      }))
      flash = action.exposures[:flash]
      _(response[0]).must_equal 302
      _(response[1]['Location']).must_equal '/legacy'
      _(flash[:failure]).must_equal 'ログインに失敗しました。'
      _(flash[:errors]).must_equal ['ユーザー名またはパスワードが違います。']
    end
  end

  describe 'do not access' do
    describe 'before initialized' do
      before { db_clear }
      after { db_reset }

      it 'redirect uninitialized' do
        response = action.call(params)
        _(response[0]).must_equal 302
        _(response[1]['Location']).must_equal '/uninitialized'
      end
    end

    describe 'in maintenace' do
      before { UpdateConfig.new.call(maintenance: true) }
      after { db_reset }

      it 'redirect maintenance' do
        response = action.call(params)
        _(response[0]).must_equal 302
        _(response[1]['Location']).must_equal '/maintenance'
      end
    end
  end
end
