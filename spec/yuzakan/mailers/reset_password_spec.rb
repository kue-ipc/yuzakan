require_relative '../../spec_helper'

describe Mailers::ResetPassword do
  it 'delivers email' do
    mail = Mailers::ResetPassword.deliver
  end
end
