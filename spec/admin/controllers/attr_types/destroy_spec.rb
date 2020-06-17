require_relative '../../../spec_helper'

describe Admin::Controllers::AttrTypes::Destroy do
  let(:action) { Admin::Controllers::AttrTypes::Destroy.new }
  let(:params) { Hash[] }

  it 'is successful' do
    response = action.call(params)
    response[0].must_equal 200
  end
end
