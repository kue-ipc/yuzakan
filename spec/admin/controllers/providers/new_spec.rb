# frozen_string_literal: true

require_relative '../../../spec_helper'

describe Admin::Controllers::Providers::New do
  let(:action) { Admin::Controllers::Providers::New.new }
  let(:params) { Hash[] }

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

  # before do
  #   db_reset
  # end
  #
  # it 'redirect setup before initialized' do
  #   db_clear
  #   response = action.call(params)
  #   response[0].must_equal 302
  #   response[1]['Location'].must_equal '/admin/setup'
  # end
  #
  # it 'redirect new_session before login after initialized' do
  #   response = action.call(params)
  #   response[0].must_equal 302
  #   response[1]['Location'].must_equal '/admin/session/new'
  # end

  # it 'is successful after initialized' do
  #   response = action.call(params)
  #   response[0].must_equal 200
  # end
end
