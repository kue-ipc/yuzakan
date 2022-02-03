require_relative '../../../spec_helper'

describe Api::Controllers::Account::Show do
  let(:action) { Api::Controllers::Account::Show.new }
  let(:params) { Hash[] }

  it 'is successful' do
    response = action.call(params)
    _(response[0]).must_equal 200
  end
end
