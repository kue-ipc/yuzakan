# frozen_string_literal: true

require_relative '../../../spec_helper'

describe Admin::Controllers::Providers::Update do
  let(:action) { Admin::Controllers::Providers::Update.new }
  let(:params) { Hash[] }

  it 'is successful' do
    response = action.call(params)
    response[0].must_equal 200
  end
end
