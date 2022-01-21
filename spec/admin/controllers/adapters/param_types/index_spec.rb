require_relative '../../../../spec_helper'

describe Admin::Controllers::Adapters::ParamTypes::Index do
  let(:action) { Admin::Controllers::Adapters::ParamTypes::Index.new }
  let(:params)  { {'REMOTE_ADDR' => '::1', 'rack.session' => session} }
  let(:session) { {user_id: user_id, access_time: Time.now} }
  let(:user_id) { Authenticate.new(client: '::1', app: 'test').call(auth).user&.id }
  let(:auth)    { {username: 'admin', password: 'pass'} }

  describe 'normal format' do
    it 'is successful' do
      response = action.call(params.merge(adapter_id: 'dummy'))
      _(response[0]).must_equal 200
      _(response[1]['Content-Type']).must_equal 'text/html; charset=utf-8'
    end
  end
end
