require_relative '../../../../spec_helper'

describe Legacy::Controllers::User::Password::Edit do
  let(:action) { Legacy::Controllers::User::Password::Edit.new }
  let(:params) { {'REMOTE_ADDR' => '::1', 'rack.session' => session} }
  let(:session) { {user_id: user_id, access_time: Time.now} }
  let(:user_id) { Authenticate.new(client: '::1', app: 'test').call(auth).user&.id }
  let(:auth) { {username: 'user', password: 'word'} }
  let(:response) { action.call(params) }
  let(:flash) { action.exposures[:flash] }

  it 'is successful' do
    _(response[0]).must_equal 200
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
