require_relative '../../../spec_helper'

describe Admin::Controllers::Home::Index do
  let(:action) { Admin::Controllers::Home::Index.new }
  let(:params) { {'REMOTE_ADDR' => '::1', 'rack.session' => session} }
  let(:session) { {user_id: user_id, access_time: Time.now} }
  let(:user_id) { Authenticate.new(client: '::1', app: 'test').call(auth).user&.id }
  let(:auth) { {username: 'admin', password: 'pass'} }

  it 'redirect dashboard' do
    response = action.call(params)
    _(response[0]).must_equal 302
    _(response[1]['Location']).must_equal '/admin/dashboard'
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
      _(response[1]['Location']).must_equal '/admin/setup'
    end
  end

  describe 'before login' do
    let(:user_id) { nil }

    it 'is unauthorized' do
      response = action.call(params)
      _(response[0]).must_equal 403
    end
  end
end
