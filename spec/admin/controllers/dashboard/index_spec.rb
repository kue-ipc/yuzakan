# frozen_string_literal: true

require_relative '../../../spec_helper'

describe Admin::Controllers::Dashboard::Index do
  let(:action) { Admin::Controllers::Dashboard::Index.new }
  let(:params) { {'REMOTE_ADDR' => '::1', 'rack.session' => session} }
  let(:session) { {user_id: user_id, access_time: Time.now} }
  let(:user_id) { Authenticate.new.call(auth).user&.id }
  let(:auth) { {username: 'admin', password: 'pass'} }

  it 'is successful' do
    response = action.call(params)
    response[0].must_equal 200
  end

  describe 'user login' do
    let(:auth) { { username: 'user', password: 'word' }}

    it 'redirect login' do
      response = action.call(params)
      response[0].must_equal 302
      response[1]['Location'].must_equal '/admin/session/new'
    end
  end

  describe 'before login' do
    let(:session) { {} }

    it 'redirect login' do
      response = action.call(params)
      response[0].must_equal 302
      response[1]['Location'].must_equal '/admin/session/new'
    end
  end

  describe 'before initialized' do
    before { db_clear }
    after { db_reset }

    it 'redirect setup' do
      response = action.call(params)
      response[0].must_equal 302
      response[1]['Location'].must_equal '/admin/setup'
    end
  end
end
