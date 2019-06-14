# frozen_string_literal: true

require_relative '../../../spec_helper'

describe Admin::Controllers::Setup::Done do
  let(:action) { Admin::Controllers::Setup::Done.new }
  let(:params) { Hash[] }

  describe 'before initialized' do
    before do
      db_clear
    end

    it 'redirect setup' do
      response = action.call(params)
      response[0].must_equal 302
      response[1]['Location'].must_equal '/admin/setup'
    end
  end

  describe 'after initialized' do
    before do
      db_reset
    end

    it 'is successful' do
      response = action.call(params)
      response[0].must_equal 200
    end
  end
end
