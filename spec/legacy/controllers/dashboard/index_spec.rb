# frozen_string_literal: true

require_relative '../../../spec_helper'

describe Legacy::Controllers::Dashboard::Index do
  let(:action) { Legacy::Controllers::Dashboard::Index.new }
  let(:params) { Hash[] }

  it 'is successful' do
    response = action.call(params)
    _(response[0]).must_equal 200
  end
end
