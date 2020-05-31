# frozen_string_literal: true

require_relative '../../../spec_helper'

describe Legacy::Controllers::Session::Destroy do
  let(:action) { Legacy::Controllers::Session::Destroy.new }
  let(:params) { {'REMOTE_ADDR' => '::1', 'rack.session' => session} }
  let(:session) { {user_id: user_id, access_time: Time.now} }
  let(:user_id) { Authenticate.new(client: '::1').call(auth).user&.id }
  let(:auth) { {username: 'user', password: 'word'} }

  it 'ridirect root' do
    response = action.call(params)
    flash = action.exposures[:flash]
    _(response[0]).must_equal 302
    _(response[1]['Location']).must_equal '/legacy'
    _(flash[:success]).must_equal 'ログアウトしました。'
  end

  describe 'no login' do
    let(:session) { {access_time: Time.now} }

    # メッセージはない。
    it 'redirect root' do
      response = action.call(params)
      _(response[0]).must_equal 302
      _(response[1]['Location']).must_equal '/legacy'
    end
  end

  describe 'do not access' do
    describe 'before initialized' do
      before { db_clear }
      after { db_reset }

      it 'redirect maintenance' do
        response = action.call(params)
        _(response[0]).must_equal 302
        _(response[1]['Location']).must_equal '/maintenance'
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
