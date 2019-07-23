# frozen_string_literal: true

require_relative '../../../../spec_helper'

describe Admin::Controllers::Adapters::Params::Index do
  let(:action) { Admin::Controllers::Adapters::Params::Index.new }
  let(:params) { {'REMOTE_ADDR' => '::1', 'rack.session' => session} }
  let(:session) { {user_id: user_id, access_time: Time.now} }
  let(:user_id) { Authenticate.new.call(auth).user&.id }
  let(:auth) { {username: 'admin', password: 'pass'} }

  describe 'json format' do
    let(:params) do
      {
        'HTTP_ACCEPT' => format,
        'rack.session' => session,
        'REMOTE_ADDR' => '::1',
      }
    end
    let(:format) { 'application/json' }

    it 'dummy is successful' do
      adapter_name = 'dummy'
      response = action.call(params.merge(adapter_id: adapter_name))
      response[0].must_equal 200
      response[1]['Content-Type'].must_equal "#{format}; charset=utf-8"
      response[2].must_equal []
    end

    it 'local is successful' do
      adapter_name = 'local'
      response = action.call(params.merge(adapter_id: adapter_name))
      response[0].must_equal 200
      response[1]['Content-Type'].must_equal "#{format}; charset=utf-8"
      response[2].must_equal []
    end

    it 'ldap is successful' do
      adapter_name = 'ldap'
      response = action.call(params.merge(adapter_id: adapter_name))
      response[0].must_equal 200
      response[1]['Content-Type'].must_equal "#{format}; charset=utf-8"
    end

    it 'ad is successful' do
      adapter_name = 'ad'
      response = action.call(params.merge(adapter_id: adapter_name))
      response[0].must_equal 200
      response[1]['Content-Type'].must_equal "#{format}; charset=utf-8"
    end

    it 'none is faild' do
      adapter_name = 'none'
      response = action.call(params.merge(adapter_id: adapter_name))
      response[0].must_equal 404
    end
  end

  describe 'normal format' do
    it 'is successful' do
      response = action.call(params.merge(adapter_id: 'dummy'))
      response[0].must_equal 200
      response[1]['Content-Type'].must_equal 'text/html; charset=utf-8'
    end
  end
end
