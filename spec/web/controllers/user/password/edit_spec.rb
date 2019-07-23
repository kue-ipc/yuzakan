# frozen_string_literal: true

require_relative '../../../../spec_helper'

describe Web::Controllers::User::Password::Edit do
  let(:action) { Web::Controllers::User::Password::Edit.new }
  let(:params) { {'REMOTE_ADDR' => '::1', 'rack.session' => session} }
  let(:session) { {user_id: user_id, access_time: Time.now} }
  let(:user_id) { Authenticate.new.call(auth).user&.id }
  let(:auth) { {username: 'user', password: 'word'} }

  # it 'is successful' do
  #   response = action.call(params)
  #   response[0].must_equal 200
  # end
end
