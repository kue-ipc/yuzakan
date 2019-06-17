# frozen_string_literal: true

require_relative '../../../spec_helper'

describe Admin::Controllers::Setup::Index do
  let(:action) { Admin::Controllers::Setup::Index.new }
  let(:params) { Hash[] }

  describe 'before initialized' do
    before do
      db_clear
    end

    after do
      db_reset
    end

    it 'is successful' do
      response = action.call(params)
      response[0].must_equal 200
    end
  end

  describe 'after initialized' do
    it 'redirect setup done' do
      response = action.call(params)
      response[0].must_equal 302
      response[1]['Location'].must_equal '/admin/setup/done'
    end
  end
end
