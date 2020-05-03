require_relative '../../../spec_helper'

describe Legacy::Controllers::Session::Destroy do
  let(:action) { Legacy::Controllers::Session::Destroy.new }
  let(:params) { Hash[] }

  it 'is successful' do
    response = action.call(params)
    response[0].must_equal 200
  end
end
