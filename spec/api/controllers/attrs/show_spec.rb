require_relative '../../../spec_helper'

describe Api::Controllers::Attrs::Show do
  let(:action) { Api::Controllers::Attrs::Show.new }
  let(:params) { Hash[] }

  it 'is successful' do
    response = action.call(params)
    _(response[0]).must_equal 200
  end
end
