require_relative '../../spec_helper'

describe Yuzakan::Utils::AccountContorl do
  let(:ac) { Yuzakan::Utils::AccountContorl.new(flags) }
  let(:flags) { Yuzakan::Utils::AccountContorl::DEFAULT_USER_FLAGS }

  it 'default user flags' do
    # NORMAL_ACCOUNT (0x0200) | DONT_EXPIRE_PASSWORD (0x10000)
    _(ac.flags).must_equal 0x10200
    _(ac.samba).must_equal '[UX         ]'
  end
end
