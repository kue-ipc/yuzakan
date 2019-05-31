require_relative '../../../spec_helper'

describe Admin::Controllers::Providers::Edit do
  let(:action) { Admin::Controllers::Providers::Edit.new }
  let(:params) { Hash[] }

  it 'is successful' do
    response = action.call(params)
    response[0].must_equal 200
  end
end
