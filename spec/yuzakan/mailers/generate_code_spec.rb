require_relative '../../spec_helper'

describe Mailers::GenerateCode do
  it 'delivers email' do
    mail = Mailers::GenerateCode.deliver
  end
end
