require_relative '../../spec_helper'

describe Mailers::UnlockUser do
  it 'delivers email' do
    mail = Mailers::UnlockUser.deliver
  end
end
