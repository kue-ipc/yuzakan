# frozen_string_literal: true

require_relative '../../../../spec_helper'

describe Legacy::Controllers::User::Password::Update do
  let(:action) { Legacy::Controllers::User::Password::Update.new }
  let(:params) do
    {
      'REMOTE_ADDR' => '::1',
      'rack.session' => session,
      user: {password: user_passwod},
    }
  end
  let(:session) { {user_id: user_id, access_time: Time.now} }
  let(:user_id) { Authenticate.new(client: '::1').call(auth).user&.id }
  let(:auth) { {username: 'user', password: 'word'} }
  let(:response) { action.call(params) }
  let(:flash) { action.exposures[:flash] }
  let(:new_password) { 'aX3od@d-2do%1o=q' }
  let(:user_passwod) do
    {
      password_current: 'word',
      password: new_password,
      password_confirmation: new_password,
    }
  end

  describe 'change passworcd' do
    after { db_reset }

    it 'is successful' do
      _(response[0]).must_equal 200
      _(flash[:success]).must_equal 'パスワードを変更しました。'
    end
  end

  describe 'wrong password_current' do
    let(:user_passwod) do
      {
        password_current: 'pass',
        password: new_password,
        password_confirmation: new_password,
      }
    end

    it 'is failed' do
      _(response[0]).must_equal 302
      _(response[1]['Location']).must_equal '/legacy/user/password/edit'
    end
  end

  describe 'too short password' do
    let(:user_passwod) do
      {
        password_current: 'word',
        password: 'a',
        password_confirmation: 'a',
      }
    end

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

      it 'redirect uninitialized' do
        _(response[0]).must_equal 302
        _(response[1]['Location']).must_equal '/uninitialized'
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
