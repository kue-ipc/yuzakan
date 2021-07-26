require_relative '../../../../spec_helper'

describe Admin::Controllers::Users::Password::Create do
  let(:action) { Admin::Controllers::Users::Password::Create.new }
  let(:params) { {'REMOTE_ADDR' => '::1', 'rack.session' => session} }
  let(:session) { {user_id: admin_id, access_time: Time.now} }
  let(:admin_id) { Authenticate.new(client: '::1', app: 'test').call(auth).user&.id }
  let(:user_id) { UserRepository.new.by_name('user').one&.id }
  let(:auth) { {username: 'admin', password: 'pass'} }

  it 'is successful' do
    response = action.call(params.merge(user_id: user_id.to_s))
    _(response[0]).must_equal 200
  end
end
