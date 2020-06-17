require_relative '../../../spec_helper'

describe Admin::Controllers::AttrTypes::Update do
  let(:action) { Admin::Controllers::AttrTypes::Update.new }
  let(:params) { Hash[] }

  it 'is successful' do
    response = action.call(params)
    response[0].must_equal 200
  end
end
