require_relative '../../../spec_helper'

describe Admin::Controllers::Users::Password::Create do
  let(:action) { Admin::Controllers::Users::Password::Create.new }
  let(:params) { Hash[] }

  it 'is successful' do
    response = action.call(params)
    _(response[0]).must_equal 200
  end
end
