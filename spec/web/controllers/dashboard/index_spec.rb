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

  describe 'do not access' do
    describe 'before login' do
      let(:session) { {} }

      it 'redirect login' do
        response = action.call(params)
        _(response[0]).must_equal 302
        _(response[1]['Location']).must_equal '/'
      end
    end

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
