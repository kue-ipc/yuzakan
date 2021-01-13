require_relative '../../../spec_helper'

describe Admin::Controllers::Adapters::Show do
  let(:action) { Admin::Controllers::Adapters::Show.new }
  let(:params) { {'REMOTE_ADDR' => '::1', 'rack.session' => session} }
  let(:session) { {user_id: user_id, access_time: Time.now} }
  let(:user_id) { Authenticate.new(client: '::1').call(auth).user&.id }
  let(:auth) { {username: 'admin', password: 'pass'} }

  it 'is successful' do
    response = action.call(params.merge(id: 'dummy'))
    _(response[0]).must_equal 200
  end
end
