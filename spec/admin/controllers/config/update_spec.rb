require_relative '../../../spec_helper'

describe Admin::Controllers::Config::Update do
  let(:action) { Admin::Controllers::Config::Update.new }
  let(:params) { Hash['rack.session' => session] }
  let(:auth) { { username: 'admin', password: 'pass' } }
  let(:session) { { user_id: Authenticate.new.call(auth).user&.id } }

  it 'is successful' do
    response = action.call(params)
    response[0].must_equal 200
  end
end
