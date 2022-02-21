require_relative '../../../spec_helper'

describe Api::Controllers::Users::Index do
  let(:action) { Api::Controllers::Users::Index.new }
  let(:params) { Hash[] }

  it 'is successful' do
    response = action.call(params)
    _(response[0]).must_equal 200
  end
end
