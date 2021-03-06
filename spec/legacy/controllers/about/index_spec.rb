require_relative '../../../spec_helper'

describe Legacy::Controllers::About::Index do
  let(:action) { Legacy::Controllers::About::Index.new }
  let(:params) { Hash[] }

  it 'is successful' do
    response = action.call(params)
    _(response[0]).must_equal 200
  end
end
