require_relative '../../spec_helper'

describe Mailers::DestroyUser do
  it 'delivers email' do
    mail = Mailers::DestroyUser.deliver
  end
end
