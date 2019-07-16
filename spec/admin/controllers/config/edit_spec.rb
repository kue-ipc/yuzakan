require_relative '../../../spec_helper'

describe Admin::Controllers::Config::Edit do
  let(:action) { Admin::Controllers::Config::Edit.new }
  let(:params) { {'rack.session' => session, 'REMOTE_ADDR' => '::1'} }
  let(:auth) { {username: 'admin', password: 'pass'} }
  let(:session) { {user_id: Authenticate.new.call(auth).user&.id} }

  it 'is successful' do
    response = action.call(params)
    response[0].must_equal 200
  end
end
