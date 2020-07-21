require_relative '../../spec_helper'

describe Mailers::AdminNotify do
  it 'delivers email' do
    mail = Mailers::AdminNotify.deliver
  end
end
