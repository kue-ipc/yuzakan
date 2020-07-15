require_relative '../../spec_helper'

describe Mailers::ChangePassword do
  it 'delivers email' do
    mail = Mailers::ChangePassword.deliver
  end
end
