# frozen_string_literal: true

require_relative '../../../spec_helper'

describe Admin::Controllers::Setup::Done do
  let(:action) { Admin::Controllers::Setup::Done.new }
  let(:params) { Hash[] }

  it 'is successful' do
    response = action.call(params)
    response[0].must_equal 200
  end
end
