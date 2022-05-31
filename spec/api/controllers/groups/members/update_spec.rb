require_relative '../../../spec_helper'

describe Api::Controllers::Groups::Members::Update do
  let(:action) { Api::Controllers::Groups::Members::Update.new }
  let(:params) { Hash[] }

  it 'is successful' do
    response = action.call(params)
    _(response[0]).must_equal 200
  end
end
