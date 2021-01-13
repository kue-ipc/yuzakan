require_relative '../../../spec_helper'

describe Web::Controllers::Dashboard::Index do
  let(:action) { Web::Controllers::Dashboard::Index.new }
  let(:params) { {'REMOTE_ADDR' => '::1', 'rack.session' => session} }
  let(:session) { {user_id: user_id, access_time: Time.now} }
  let(:user_id) { Authenticate.new(client: '::1').call(auth).user&.id }
  let(:auth) { {username: 'user', password: 'word'} }

  it 'is successful' do
    response = action.call(params)
    _(response[0]).must_equal 200
    _(action.send(:remote_ip).to_s).must_equal '::1'
  end

  describe 'admin login' do
    let(:auth) { {username: 'admin', password: 'pass'} }

    it 'is successful' do
      response = action.call(params)
      _(response[0]).must_equal 200
    end
  end

  describe 'session timeout' do
    let(:session) { {user_id: user_id, access_time: Time.now - 24 * 60 * 60} }

    it 'redirect login with flash' do
      response = action.call(params)
      flash = action.exposures[:flash]
      _(response[0]).must_equal 302
      _(response[1]['Location']).must_equal '/'
      _(flash[:warn]).must_equal 'セッションがタイムアウトしました。' \
          'ログインし直してください。'
    end
  end

  describe 'no usner_id' do
    let(:session) { {access_time: Time.now} }

    it 'redirect login' do
      response = action.call(params)
      flash = action.exposures[:flash]
      _(response[0]).must_equal 302
      _(response[1]['Location']).must_equal '/'
      _(flash[:warn]).must_be_nil
    end
  end

  describe 'no access_time' do
    let(:session) { {user_id: user_id} }

    it 'redirect login' do
      response = action.call(params)
      flash = action.exposures[:flash]
      _(response[0]).must_equal 302
      _(response[1]['Location']).must_equal '/'
      _(flash[:warn]).must_equal 'セッションがタイムアウトしました。ログインし直してください。'
    end
  end

  describe 'no session' do
    let(:session) { {} }

    it 'redirect login' do
      response = action.call(params)
      flash = action.exposures[:flash]
      _(response[0]).must_equal 302
      _(response[1]['Location']).must_equal '/'
      _(flash[:warn]).must_be_nil
    end
  end

  describe 'short 1min timeout' do
    before { UpdateConfig.new.call(session_timeout: 60) }
    after { db_reset }

    describe '10 sec' do
      let(:session) { {user_id: user_id, access_time: Time.now - 10} }

      it 'is successful' do
        response = action.call(params)
        _(response[0]).must_equal 200
      end
    end

    describe '120 sec' do
      let(:session) { {user_id: user_id, access_time: Time.now - 120} }

      it 'redirect login' do
        response = action.call(params)
        flash = action.exposures[:flash]
        _(response[0]).must_equal 302
        _(response[1]['Location']).must_equal '/'
        _(flash[:warn]).must_equal 'セッションがタイムアウトしました。' \
            'ログインし直してください。'
      end
    end
  end
end
