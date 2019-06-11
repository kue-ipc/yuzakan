# frozen_string_literal: true

require_relative '../../../spec_helper'

describe Admin::Controllers::Setup::Done do
  let(:action) { Admin::Controllers::Setup::Done.new }
  let(:params) { Hash[] }

  before do
    db_reset
  end

  it 'redirect setup before initialized' do
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
