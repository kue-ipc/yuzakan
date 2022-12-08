require_relative '../../../spec_helper'

describe Yuzakan::Adapters::SambaLdapAdapter::SambaAccountControl do
  let(:ac) { Yuzakan::Adapters::SambaLdapAdapter::SambaAccountControl.new(flags) }
  let(:flags) { Yuzakan::Adapters::SambaLdapAdapter::SambaAccountControl::DEFAULT_USER_FLAGS }

  it 'user flags' do
    # NORMAL_ACCOUNT (0x0200) | DONT_EXPIRE_PASSWORD (0x10000)
    _(ac.to_i).must_equal 0x10200
    _(ac.to_s).must_equal '[UX         ]'
    _(ac.intersect?(
        Yuzakan::Adapters::SambaLdapAdapter::SambaAccountControl::Flag::ACCOUNTDISABLE |
        Yuzakan::Adapters::SambaLdapAdapter::SambaAccountControl::Flag::LOCKOUT)).must_equal false
  end

  let 'enable' do
    ac.delete(Yuzakan::Adapters::SambaLdapAdapter::SambaAccountControl::Flag::ACCOUNTDISABLE)
    _(ac.to_i).must_equal 0x10200
    _(ac.to_s).must_equal '[UX         ]'
    _(ac.intersect?(
        Yuzakan::Adapters::SambaLdapAdapter::SambaAccountControl::Flag::ACCOUNTDISABLE |
        Yuzakan::Adapters::SambaLdapAdapter::SambaAccountControl::Flag::LOCKOUT)).must_equal false
  end

  it 'disable' do
    ac << Yuzakan::Adapters::SambaLdapAdapter::SambaAccountControl::Flag::ACCOUNTDISABLE
    _(ac.to_i).must_equal 0x10202
    _(ac.to_s).must_equal '[DUX        ]'
    _(ac.intersect?(
        Yuzakan::Adapters::SambaLdapAdapter::SambaAccountControl::Flag::ACCOUNTDISABLE |
        Yuzakan::Adapters::SambaLdapAdapter::SambaAccountControl::Flag::LOCKOUT)).must_equal true
  end

  it 'new string' do
    new_ac = Yuzakan::Adapters::SambaLdapAdapter::SambaAccountControl.new('[UX         ]')
    _(new_ac == ac).must_equal true
  end

  describe 'disbaled user' do
    # ACCOUNTDISABLE 0x0002
    let(:flags) {
      Yuzakan::Adapters::SambaLdapAdapter::SambaAccountControl::DEFAULT_USER_FLAGS |
        Yuzakan::Adapters::SambaLdapAdapter::SambaAccountControl::Flag::ACCOUNTDISABLE
    }

    let 'user flags' do
      _(ac.to_i).must_equal 0x10202
      _(ac.to_s).must_equal '[DUX        ]'
      _(ac.intersect?(
          Yuzakan::Adapters::SambaLdapAdapter::SambaAccountControl::Flag::ACCOUNTDISABLE |
          Yuzakan::Adapters::SambaLdapAdapter::SambaAccountControl::Flag::LOCKOUT)).must_equal true
    end

    let 'enable' do
      ac.delete(Yuzakan::Adapters::SambaLdapAdapter::SambaAccountControl::Flag::ACCOUNTDISABLE)
      _(ac.to_i).must_equal 0x10200
      _(ac.to_s).must_equal '[UX         ]'
      _(ac.intersect?(
          Yuzakan::Adapters::SambaLdapAdapter::SambaAccountControl::Flag::ACCOUNTDISABLE |
          Yuzakan::Adapters::SambaLdapAdapter::SambaAccountControl::Flag::LOCKOUT)).must_equal false
    end

    it 'disable' do
      ac << Yuzakan::Adapters::SambaLdapAdapter::SambaAccountControl::Flag::ACCOUNTDISABLE
      _(ac.to_i).must_equal 0x10202
      _(ac.to_s).must_equal '[DUX        ]'
      _(ac.intersect?(
          Yuzakan::Adapters::SambaLdapAdapter::SambaAccountControl::Flag::ACCOUNTDISABLE |
          Yuzakan::Adapters::SambaLdapAdapter::SambaAccountControl::Flag::LOCKOUT)).must_equal true
    end

    it 'new string' do
      new_ac = Yuzakan::Adapters::SambaLdapAdapter::SambaAccountControl.new('[UXD        ]')
      _(new_ac == ac).must_equal true
    end
  end

  describe 'locked user' do
    let(:flags) {
      Yuzakan::Adapters::SambaLdapAdapter::SambaAccountControl::DEFAULT_USER_FLAGS |
        Yuzakan::Adapters::SambaLdapAdapter::SambaAccountControl::Flag::LOCKOUT
    }

    let 'user flags' do
      _(ac.to_i).must_equal 0x10212
      _(ac.to_s).must_equal '[LUX        ]'
      _(ac.intersect?(
          Yuzakan::Adapters::SambaLdapAdapter::SambaAccountControl::Flag::ACCOUNTDISABLE |
          Yuzakan::Adapters::SambaLdapAdapter::SambaAccountControl::Flag::LOCKOUT)).must_equal true
    end

    let 'enable' do
      ac.delete(Yuzakan::Adapters::SambaLdapAdapter::SambaAccountControl::Flag::ACCOUNTDISABLE)
      _(ac.to_i).must_equal 0x10210
      _(ac.to_s).must_equal '[LUX        ]'
      _(ac.intersect?(
          Yuzakan::Adapters::SambaLdapAdapter::SambaAccountControl::Flag::ACCOUNTDISABLE |
          Yuzakan::Adapters::SambaLdapAdapter::SambaAccountControl::Flag::LOCKOUT)).must_equal true
    end

    it 'disable' do
      ac << Yuzakan::Adapters::SambaLdapAdapter::SambaAccountControl::Flag::ACCOUNTDISABLE
      _(ac.to_i).must_equal 0x10212
      _(ac.to_s).must_equal '[DLUX       ]'
      _(ac.intersect?(
          Yuzakan::Adapters::SambaLdapAdapter::SambaAccountControl::Flag::ACCOUNTDISABLE |
          Yuzakan::Adapters::SambaLdapAdapter::SambaAccountControl::Flag::LOCKOUT)).must_equal true
    end

    it 'new string' do
      new_ac = Yuzakan::Adapters::SambaLdapAdapter::SambaAccountControl.new('[UXL        ]')
      _(new_ac == ac).must_equal true
    end
  end

  describe 'disabled and locked user' do
    let(:flags) {
      Yuzakan::Adapters::SambaLdapAdapter::SambaAccountControl::DEFAULT_USER_FLAGS |
        Yuzakan::Adapters::SambaLdapAdapter::SambaAccountControl::Flag::ACCOUNTDISABLE |
        Yuzakan::Adapters::SambaLdapAdapter::SambaAccountControl::Flag::LOCKOUT
    }

    let 'user flags' do
      _(ac.to_i).must_equal 0x10212
      _(ac.to_s).must_equal '[DLUX       ]'
      _(ac.intersect?(
          Yuzakan::Adapters::SambaLdapAdapter::SambaAccountControl::Flag::ACCOUNTDISABLE |
          Yuzakan::Adapters::SambaLdapAdapter::SambaAccountControl::Flag::LOCKOUT)).must_equal true
    end

    let 'enable' do
      ac.delete(Yuzakan::Adapters::SambaLdapAdapter::SambaAccountControl::Flag::ACCOUNTDISABLE)
      _(ac.to_i).must_equal 0x10210
      _(ac.to_s).must_equal '[LUX        ]'
      _(ac.intersect?(
          Yuzakan::Adapters::SambaLdapAdapter::SambaAccountControl::Flag::ACCOUNTDISABLE |
          Yuzakan::Adapters::SambaLdapAdapter::SambaAccountControl::Flag::LOCKOUT)).must_equal true
    end

    it 'disable' do
      ac << Yuzakan::Adapters::SambaLdapAdapter::SambaAccountControl::Flag::ACCOUNTDISABLE
      _(ac.to_i).must_equal 0x10212
      _(ac.to_s).must_equal '[DLUX       ]'
      _(ac.intersect?(
          Yuzakan::Adapters::SambaLdapAdapter::SambaAccountControl::Flag::ACCOUNTDISABLE |
          Yuzakan::Adapters::SambaLdapAdapter::SambaAccountControl::Flag::LOCKOUT)).must_equal true
    end
  end
end
