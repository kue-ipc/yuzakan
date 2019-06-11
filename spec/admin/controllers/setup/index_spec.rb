# frozen_string_literal: true

require_relative '../../../spec_helper'

describe Admin::Controllers::Setup::Index do
  let(:action) { Admin::Controllers::Setup::Index.new }
  let(:params) { Hash[] }

  before do
    db_reset
    db_initialize
  end

  it 'is successful' do
    db_clear
    response = action.call(params)
    response[0].must_equal 200
  end

  it 'redirect setup done after initialized' do
    db_clear
    response = action.call(params)
    response[0].must_equal 302
    response[1]['Location'].must_equal '/admin/setup'
  end

  it 'is successful after initialized' do
    response = action.call(params)
    response[0].must_equal 200
  end

end
