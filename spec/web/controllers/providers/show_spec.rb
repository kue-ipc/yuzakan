require_relative '../../../spec_helper'

describe Web::Controllers::Providers::Show do
  let(:action) { Web::Controllers::Providers::Show.new }
  let(:params) { Hash[] }

  it 'is successful' do
    response = action.call(params)
    _(response[0]).must_equal 200
  end
end
