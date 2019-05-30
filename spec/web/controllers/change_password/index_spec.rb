# frozen_string_literal: true

require_relative '../../../spec_helper'

describe Web::Controllers::ChangePassword::Index do
  let(:action) { Web::Controllers::ChangePassword::Index.new }
  let(:params) { Hash[] }

  it 'is successful' do
    response = action.call(params)
    response[0].must_equal 200
  end
end
