# frozen_string_literal: true

require_relative '../../../spec_helper'

describe Web::Controllers::Dashboard::Index do
  let(:action) { Web::Controllers::Dashboard::Index.new }
  let(:params) { {'REMOTE_ADDR' => '::1', 'rack.session' => session} }
  let(:session) { {user_id: user_id, access_time: Time.now} }
  let(:user_id) { Authenticate.new.call(auth).user&.id }
  let(:auth) { {username: 'user', password: 'word'} }

  it 'is successful' do
    response = action.call(params)
    response[0].must_equal 200
    action.send(:remote_ip).to_s.must_equal '::1'
  end

  describe 'admin login' do
    let(:auth) { {username: 'admin', password: 'pass'} }

    it 'is successful' do
      response = action.call(params)
      response[0].must_equal 200
    end
  end

  describe 'session timeout' do
    let(:session) { {user_id: user_id, access_time: Time.now - 24 * 60 * 60} }

    it 'redirect login with flash' do
      response = action.call(params)
      flash = action.exposures[:flash]
      response[0].must_equal 302
      response[1]['Location'].must_equal '/session/new'
      flash[:warn].must_equal 'セッションがタイムアウトしました。' \
          'ログインし直してください。'
    end
  end

  describe 'no usner_id' do
    let(:session) { {access_time: Time.now} }

    it 'redirect login' do
      response = action.call(params)
      flash = action.exposures[:flash]
      response[0].must_equal 302
      response[1]['Location'].must_equal '/session/new'
      flash[:warn].must_be_nil
    end
  end

  describe 'no access_time' do
    let(:session) { {user_id: user_id} }

    it 'redirect login' do
      response = action.call(params)
      flash = action.exposures[:flash]
      response[0].must_equal 302
      response[1]['Location'].must_equal '/session/new'
      flash[:warn].must_be_nil
    end
  end

  describe 'no session' do
    let(:session) { {} }

    it 'redirect login' do
      response = action.call(params)
      flash = action.exposures[:flash]
      response[0].must_equal 302
      response[1]['Location'].must_equal '/session/new'
      flash[:warn].must_be_nil
    end
  end

  describe 'short 1min timeout' do
    before { UpdateConfig.new.call(session_timeout: 60) }
    after { db_reset }

    describe '10 sec' do
      let(:session) { {user_id: user_id, access_time: Time.now - 10} }

      it 'is successful' do
        response = action.call(params)
        response[0].must_equal 200
      end
    end

    describe '120 sec' do
      let(:session) { {user_id: user_id, access_time: Time.now - 120} }

      it 'redirect login' do
        response = action.call(params)
        flash = action.exposures[:flash]
        response[0].must_equal 302
        response[1]['Location'].must_equal '/session/new'
        flash[:warn].must_equal 'セッションがタイムアウトしました。' \
            'ログインし直してください。'
      end
    end
  end

  describe 'do not access' do
    describe 'before login' do
      let(:session) { {} }

      it 'redirect login' do
        response = action.call(params)
        response[0].must_equal 302
        response[1]['Location'].must_equal '/session/new'
      end
    end

    describe 'before initialized' do
      before { db_clear }
      after { db_reset }

      it 'redirect maintenance' do
        response = action.call(params)
        response[0].must_equal 302
        response[1]['Location'].must_equal '/maintenance'
      end
    end

    describe 'in maintenace' do
      before { UpdateConfig.new.call(maintenance: true) }
      after { db_reset }

      it 'redirect maintenance' do
        response = action.call(params)
        response[0].must_equal 302
        response[1]['Location'].must_equal '/maintenance'
      end
    end
  end

  describe 'check remote ip' do
    before { UpdateConfig.new.call(
      remote_ip_header: 'X-Forwarded-For',
      trusted_reverse_proxies: '::1 127.0.0.1') }
    after { db_reset }

    it 'remote_ip is not ::1' do
      response = action.call(params.merge(
        'HTTP_X_FORWARDED_FOR' => '192.168.1.1'))
      response[0].must_equal 200
      action.send(:remote_ip).to_s.must_equal '192.168.1.1'
    end

    it 'remote_ip is not 127.0.0.1' do
      response = action.call(params.merge(
        'REMOTE_ADDR' => '127.0.0.1',
        'HTTP_X_FORWARDED_FOR' => '192.168.1.1'))
      response[0].must_equal 200
      action.send(:remote_ip).to_s.must_equal '192.168.1.1'
    end

    it 'remote_ip is first' do
      response = action.call(params.merge(
        'HTTP_X_FORWARDED_FOR' =>
          '192.168.10.10, 192.168.20.20, 192.168.30.30'))
      response[0].must_equal 200
      action.send(:remote_ip).to_s.must_equal '192.168.10.10'
    end

    it 'fake remote_ip' do
      response = action.call(params.merge(
        'REMOTE_ADDR' => '172.16.1.1',
        'HTTP_X_FORWARDED_FOR' => '192.168.1.1'))
      response[0].must_equal 200
      action.send(:remote_ip).to_s.must_equal '172.16.1.1'
    end

    it 'other remote_ip' do
      response = action.call(params.merge(
        'REMOTE_ADDR' => '172.16.1.1'))
      response[0].must_equal 200
      action.send(:remote_ip).to_s.must_equal '172.16.1.1'
    end
  end

  describe 'check x-real-ip' do
    before { UpdateConfig.new.call(
      remote_ip_header: 'X-Real-Ip',
      trusted_reverse_proxies: '::1 127.0.0.1') }
    after { db_reset }

    it 'remote_ip is not ::1' do
      response = action.call(params.merge(
        'HTTP_X_REAL_IP' => '192.168.1.1'))
      response[0].must_equal 200
      action.send(:remote_ip).to_s.must_equal '192.168.1.1'
    end
  end
end
