# frozen_string_literal: true

require_relative '../../../../spec_helper'

describe Admin::Controllers::Adapters::Params::Index do
  let(:action) { Admin::Controllers::Adapters::Params::Index.new }
  let(:params) { Hash['rack.session' => session] }
  let(:auth) { { username: 'admin', password: 'pass' } }
  let(:session) { { user_id: Login.new.call(auth).user&.id } }

  describe 'json format' do
    let(:format) { 'application/json' }

    it 'DummyAdapter is successful' do
      adapter_name = 'DummyAdapter'
      response = action.call(params.merge(
        adapter_id: adapter_name,
        'HTTP_ACCEPT' => format,
      ))
      response[0].must_equal 200
      response[1]['Content-Type'].must_equal "#{format}; charset=utf-8"
      response[2].must_equal []
    end

    it 'LocalAdapter is successful' do
      adapter_name = 'LocalAdapter'
      response = action.call(params.merge(
        adapter_id: adapter_name,
        'HTTP_ACCEPT' => format,
      ))
      response[0].must_equal 200
      response[1]['Content-Type'].must_equal "#{format}; charset=utf-8"
      response[2].must_equal []
    end

    it 'LadpAdapter is successful' do
      adapter_name = 'LdapAdapter'
      response = action.call(params.merge(
        adapter_id: adapter_name,
        'HTTP_ACCEPT' => format,
      ))
      response[0].must_equal 200
      response[1]['Content-Type'].must_equal "#{format}; charset=utf-8"
    end

    it 'ActiveDirectoryAdapter is successful' do
      adapter_name = 'ActiveDirectoryAdapter'
      response = action.call(params.merge(
        adapter_id: adapter_name,
        'HTTP_ACCEPT' => format,
      ))
      response[0].must_equal 200
      response[1]['Content-Type'].must_equal "#{format}; charset=utf-8"
    end

    it 'NonAdapter is faild' do
      adapter_name = 'NonAdapter'
      response = action.call(params.merge(
        adapter_id: adapter_name,
        'HTTP_ACCEPT' => format,
      ))
      response[0].must_equal 404
    end
  end

  describe 'normal format' do
    it 'LdapAdapter is successful' do
      adapter_name = 'LdapAdapter'
      response = action.call(params.merge(
        adapter_id: adapter_name,
      ))
      response[0].must_equal 200
      response[1]['Content-Type'].must_equal 'text/html; charset=utf-8'
    end
  end
end
