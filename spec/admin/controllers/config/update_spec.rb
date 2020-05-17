# frozen_string_literal: true

require_relative '../../../spec_helper'

describe Admin::Controllers::Config::Update do
  let(:action) { Admin::Controllers::Config::Update.new }
  let(:params) { {'REMOTE_ADDR' => '::1', 'rack.session' => session} }
  let(:session) { {user_id: user_id, access_time: Time.now} }
  let(:user_id) { Authenticate.new(client: '::1').call(auth).user&.id }
  let(:auth) { {username: 'admin', password: 'pass'} }

  it 'is successful' do
    response = action.call(params)
    _(response[0]).must_equal 302
    _(response[1]['Location']).must_equal '/admin/config/edit'
  end
end
