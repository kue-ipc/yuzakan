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
  end

  describe 'admin login' do
    let(:auth) { {username: 'admin', password: 'pass'} }

    it 'is successful' do
      response = action.call(params)
      response[0].must_equal 200
    end
  end

  describe 'before login' do
    let(:session) { {} }

    it 'redirect login' do
      response = action.call(params)
      response[0].must_equal 302
      response[1]['Location'].must_equal '/session/new'
    end
  end

  describe 'session timeout' do
    let(:session) { {user_id: user_id, access_time: Time.now - 24 * 60 * 60} }

    it 'redirect login' do
      response = action.call(params)
      flash = action.exposures[:flash]
      response[0].must_equal 302
      response[1]['Location'].must_equal '/session/new'
      flash[:warn].must_equal 'セッションがタイムアウトしました。' \
          'ログインし直してください。'
    end
  end

  describe 'short 1min timeout' do
    before { UpdateConfig.new.call(session_timeout: 60) }
    after { db_reset}

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




end
