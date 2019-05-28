require_relative '../../../spec_helper'

describe Web::Controllers::User::ChangePassword do
  let(:action) { Web::Controllers::User::ChangePassword.new }
  let(:params) { Hash[] }

  it 'is successful' do
    response = action.call(params)
    response[0].must_equal 200
  end
end
