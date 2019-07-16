# frozen_string_literal: true

require_relative '../../../spec_helper'

describe Admin::Controllers::Adapters::Show do
  let(:action) { Admin::Controllers::Adapters::Show.new }
  let(:params) do
    {
      id: adapter_name,
      'rack.session' => session,
      'REMOTE_ADDR' => '::1',
    }
  end
  let(:auth) { {username: 'admin', password: 'pass'} }
  let(:session) { {user_id: Authenticate.new.call(auth).user&.id} }
  let(:adapter_name) { 'dummy' }

  it 'is successful' do
    response = action.call(params)
    response[0].must_equal 200
  end
end
