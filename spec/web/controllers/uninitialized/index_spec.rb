require_relative '../../../spec_helper'

describe Web::Controllers::Uninitialized::Index do
  let(:action) { Web::Controllers::Uninitialized::Index.new }
  let(:params) { {'REMOTE_ADDR' => '::1', 'rack.session' => session} }
  let(:session) { {user_id: user_id, access_time: Time.now} }
  let(:user_id) { Authenticate.new(client: '::1', app: 'test').call(auth).user&.id }
  let(:auth) { {username: 'user', password: 'word'} }

  it 'redirect root' do
    response = action.call(params)
    _(response[0]).must_equal 302
    _(response[1]['Location']).must_equal '/'
  end

  describe 'before login' do
    let(:session) { {} }

    it 'redirect root' do
      response = action.call(params)
      _(response[0]).must_equal 302
      _(response[1]['Location']).must_equal '/'
    end
  end

  describe 'before initialized' do
    before { db_clear }
    after { db_reset }

    it 'is successful' do
      response = action.call(params)
      _(response[0]).must_equal 200
    end
  end

  describe 'in maintenace' do
    before { UpdateConfig.new.call(maintenance: true) }
    after { db_reset }

    it 'redirect root' do
      response = action.call(params)
      _(response[0]).must_equal 302
      _(response[1]['Location']).must_equal '/'
    end
  end
end
