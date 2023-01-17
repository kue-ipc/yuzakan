# frozen_string_literal: true

RSpec.describe Yuzakan::Adapters::SambaLdapAdapter::SambaAccountControl do
  let(:ac) { Yuzakan::Adapters::SambaLdapAdapter::SambaAccountControl.new(flags) }
  let(:flags) { Yuzakan::Adapters::SambaLdapAdapter::SambaAccountControl::DEFAULT_USER_FLAGS }

  it 'user flags' do
    # NORMAL_ACCOUNT (0x0200) | DONT_EXPIRE_PASSWORD (0x10000)
    expect(ac.to_s).to eq '[UX         ]'
  end

  it 'enable' do
    ac.accountdisable = false
    expect(ac.to_s).to eq '[UX         ]'
  end

  it 'disable' do
    ac.accountdisable = true
    expect(ac.to_s).to eq '[DUX        ]'
  end

  it 'new string' do
    new_ac = Yuzakan::Adapters::SambaLdapAdapter::SambaAccountControl.new('[UX         ]')
    expect(new_ac == ac).to eq true
  end

  it 'set PASSWORD_EXPIRED' do
    ac.password_expired = true
    expect(ac.to_s).to eq '[UX         ]' # no change
  end

  describe 'disbaled user' do
    # ACCOUNTDISABLE 0x0002
    let(:flags) {
      Yuzakan::Adapters::SambaLdapAdapter::SambaAccountControl::DEFAULT_USER_FLAGS |
        Yuzakan::Adapters::SambaLdapAdapter::SambaAccountControl::Flag::ACCOUNTDISABLE
    }

    it 'user flags' do
      expect(ac.to_s).to eq '[DUX        ]'
    end

    it 'enable' do
      ac.accountdisable = false
      expect(ac.to_s).to eq '[UX         ]'
    end

    it 'disable' do
      ac.accountdisable = true
      expect(ac.to_s).to eq '[DUX        ]'
    end

    it 'new string' do
      new_ac = Yuzakan::Adapters::SambaLdapAdapter::SambaAccountControl.new('[UXD        ]')
      expect(new_ac == ac).to eq true
    end
  end

  describe 'locked user' do
    let(:flags) {
      Yuzakan::Adapters::SambaLdapAdapter::SambaAccountControl::DEFAULT_USER_FLAGS |
        Yuzakan::Adapters::SambaLdapAdapter::SambaAccountControl::Flag::LOCKOUT
    }

    it 'user flags' do
      expect(ac.to_s).to eq '[LUX        ]'
    end

    it 'enable' do
      ac.accountdisable = false
      expect(ac.to_s).to eq '[LUX        ]'
    end

    it 'disable' do
      ac.accountdisable = true
      expect(ac.to_s).to eq '[DLUX       ]'
    end

    it 'new string' do
      new_ac = Yuzakan::Adapters::SambaLdapAdapter::SambaAccountControl.new('[UXL        ]')
      expect(new_ac == ac).to eq true
    end
  end

  describe 'disabled and locked user' do
    let(:flags) {
      Yuzakan::Adapters::SambaLdapAdapter::SambaAccountControl::DEFAULT_USER_FLAGS |
        Yuzakan::Adapters::SambaLdapAdapter::SambaAccountControl::Flag::ACCOUNTDISABLE |
        Yuzakan::Adapters::SambaLdapAdapter::SambaAccountControl::Flag::LOCKOUT
    }

    it 'user flags' do
      expect(ac.to_s).to eq '[DLUX       ]'
    end

    it 'enable' do
      ac.accountdisable = false
      expect(ac.to_s).to eq '[LUX        ]'
    end

    it 'disable' do
      ac.accountdisable = true
      expect(ac.to_s).to eq '[DLUX       ]'
    end
  end
end
