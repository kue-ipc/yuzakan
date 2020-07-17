require_relative '../../spec_helper'

describe Mailers::CreateUser do
  it 'delivers email' do
    mail = Mailers::CreateUser.deliver
  end
end
