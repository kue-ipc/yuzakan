# frozen_string_literal: true

require_relative '../../../spec_helper'

describe Admin::Controllers::Session::Create do
  let(:action) { Admin::Controllers::Session::Create.new }
  let(:params) { {'REMOTE_ADDR' => '::1'} }

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

  # describe 'not authenicated' do
  #   it 'is successful' do
  #     response = action.call(params)
  #     response[0].must_equal 200
  #   end
  # end
  #
  # describe 'authenticated' do
  #   it 'is successful' do
  #     response = action.call(params)
  #     response[0].must_equal 200
  #   end
  # end

  # it 'is successful' do
  #   response = action.call(params)
  #   response[0].must_equal 200
  # end
end
