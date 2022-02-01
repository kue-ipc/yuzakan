require_relative '../../../spec_helper'

describe Admin::Controllers::Home::Index do
  let(:action) { Admin::Controllers::Home::Index.new }
  let(:params) { {'REMOTE_ADDR' => '::1', 'rack.session' => session} }
  let(:session) { {user_id: user_id, access_time: Time.now} }
  let(:user_id) { Authenticate.new(client: '::1', app: 'test').call(auth).user&.id }
  let(:auth) { {username: 'admin', password: 'pass'} }

  it 'is successful' do
    response = action.call(params)
    _(response[0]).must_equal 200
  end

  describe 'before initialized' do
    before do
      db_clear
    end

    after do
      db_reset
    end

    it 'redirect setup' do
      response = action.call(params)
      _(response[0]).must_equal 302
      _(response[1]['Location']).must_equal '/uninitialized'
    end
  end

  describe 'before login' do
    let(:user_id) { nil }

    it 'is unauthorized' do
      response = action.call(params)
      _(response[0]).must_equal 302
      _(response[1]['Location']).must_equal '/'
    end
  end
end
