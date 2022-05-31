require_relative '../../../spec_helper'

describe Api::Controllers::Groups::Members::Index do
  let(:action) { Api::Controllers::Groups::Members::Index.new }
  let(:params) { Hash[] }

  it 'is successful' do
    response = action.call(params)
    _(response[0]).must_equal 200
  end
end
