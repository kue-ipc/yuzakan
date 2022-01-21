require_relative '../../spec_helper'

describe Mailers::AdminNotify do
  it 'delivers email' do
    _mail = Mailers::AdminNotify.deliver
  end
end
