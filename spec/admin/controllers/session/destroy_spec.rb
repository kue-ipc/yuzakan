# frozen_string_literal: true

require_relative '../../../spec_helper'

describe Admin::Controllers::Session::Destroy do
  let(:action) { Admin::Controllers::Session::Destroy.new }
  let(:params) { {'REMOTE_ADDR' => '::1', 'rack.session' => session} }
  let(:session) { {user_id: user_id, access_time: Time.now} }
  let(:user_id) { Authenticate.new.call(auth).user&.id }
  let(:auth) { {username: 'admin', password: 'pass'} }

  describe 'before initialized' do
    before { db_clear }
    after { db_reset }

    it 'redirect setup' do
      response = action.call(params)
      response[0].must_equal 302
      response[1]['Location'].must_equal '/admin/setup'
    end
  end

  describe 'before_login' do
    let(:user_id) { nil }

    it 'redirect login' do
      response = action.call(params)
      response[0].must_equal 302
      response[1]['Location'].must_equal '/admin/session/new'
    end
  end
end
