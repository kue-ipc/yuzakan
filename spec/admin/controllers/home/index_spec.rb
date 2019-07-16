# frozen_string_literal: true

require_relative '../../../spec_helper'

describe Admin::Controllers::Home::Index do
  let(:action) { Admin::Controllers::Home::Index.new }
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

  describe 'after initialized' do
    it 'is successful' do
      response = action.call(params)
      response[0].must_equal 200
    end
  end
end
