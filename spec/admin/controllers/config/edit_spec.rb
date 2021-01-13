require_relative '../../../spec_helper'

describe Admin::Controllers::Config::Edit do
  let(:action) { Admin::Controllers::Config::Edit.new }
  let(:params) { {'REMOTE_ADDR' => '::1', 'rack.session' => session} }
  let(:session) { {user_id: user_id, access_time: Time.now} }
  let(:user_id) { Authenticate.new(client: '::1', app: 'test').call(auth).user&.id }
  let(:auth) { {username: 'admin', password: 'pass'} }

  it 'is successful' do
    response = action.call(params)
    _(response[0]).must_equal 200
  end
end
