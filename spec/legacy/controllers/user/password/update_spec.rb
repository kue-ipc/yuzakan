# frozen_string_literal: true

require_relative '../../../../spec_helper'

describe Legacy::Controllers::User::Password::Update do
  let(:action) { Legacy::Controllers::User::Password::Update.new }
  let(:params) { {
    'REMOTE_ADDR' => '::1',
    'rack.session' => session,
    user: {password: user_passwod},
  } }
  let(:session) { {user_id: user_id, access_time: Time.now} }
  let(:user_id) { Authenticate.new.call(auth).user&.id }
  let(:auth) { {username: 'user', password: 'word'} }
  let(:response) { action.call(params) }
  let(:flash) { action.exposures[:flash] }
  let(:new_password) { '1\'a;qo,23.ejkup4' }
  let(:user_passwod) { {
    password_current: 'word',
    password: new_password,
    password_confirmation: new_password,
  } }

  it 'is successful' do
    _(response[0]).must_equal 200
    _(flash[:success]).must_equal 'パスワードを変更しました。'
  end

  describe 'wrong password_current' do
    let(:user_passwod) { {
      password_current: 'pass',
      password: new_password,
      password_confirm: new_password,
    } }

    it 'is failed' do
      _(response[0]).must_equal 302
      _(response[1]['Location']).must_equal '/legacy/user/password/edit'
    end
  end

  describe 'too short password' do
    let(:user_passwod) { {
      password_current: 'word',
      password: 'a',
      password_confirm: 'a',
    } }

    it 'is failed' do
      _(response[0]).must_equal 302
      _(response[1]['Location']).must_equal '/legacy/user/password/edit'
    end
  end

  describe 'do not access' do
    describe 'no login' do
      let(:session) { {access_time: Time.now} }

      it 'redirect root' do
        _(response[0]).must_equal 302
        _(response[1]['Location']).must_equal '/legacy'
      end
    end

    describe 'before initialized' do
      before { db_clear }
      after { db_reset }

      it 'redirect maintenance' do
        _(response[0]).must_equal 302
        _(response[1]['Location']).must_equal '/maintenance'
      end
    end

    describe 'in maintenace' do
      before { UpdateConfig.new.call(maintenance: true) }
      after { db_reset }

      it 'redirect maintenance' do
        _(response[0]).must_equal 302
        _(response[1]['Location']).must_equal '/maintenance'
      end
    end
  end
end
