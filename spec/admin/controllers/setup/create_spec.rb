# frozen_string_literal: true

require_relative '../../../spec_helper'

describe Admin::Controllers::Setup::Create do
  let(:action) { Admin::Controllers::Setup::Create.new }
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
end
