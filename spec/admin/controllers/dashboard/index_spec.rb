# frozen_string_literal: true

require_relative '../../../spec_helper'

describe Admin::Controllers::Dashboard::Index do
  let(:action) { Admin::Controllers::Dashboard::Index.new }
  let(:params) { {'REMOTE_ADDR' => '::1', 'rack.session' => session} }
  let(:auth) { { username: 'admin', password: 'pass' } }
  let(:session) { { user_id: Authenticate.new.call(auth).user&.id } }

  describe 'before initialized' do
    before do
      db_clear
    end

    after do
      db_reset
    end

    it 'redirect setup' do
      response = action.call(params)
      response[0].must_equal 302
      response[1]['Location'].must_equal '/admin/setup'
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

  describe 'user login' do
    let(:auth) { { username: 'user', password: 'word' }}

    it 'redirect login' do
      response = action.call(params)
      response[0].must_equal 302
      response[1]['Location'].must_equal '/admin/session/new'
    end
  end

  it 'is successful' do
    response = action.call(params)
    response[0].must_equal 200
  end
end
