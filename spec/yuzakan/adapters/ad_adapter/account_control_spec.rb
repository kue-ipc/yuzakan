require_relative '../../../spec_helper'

describe Yuzakan::Adapters::AdAdapter::AccountContorl do
  let(:ac) { Yuzakan::Adapters::AdAdapter::AccountContorl.new(flags) }
  let(:flags) { Yuzakan::Adapters::AdAdapter::AccountContorl::DEFAULT_USER_FLAGS }

  it 'user flags' do
    # NORMAL_ACCOUNT (0x0200) | DONT_EXPIRE_PASSWORD (0x10000)
    _(ac.flags).must_equal 0x10200
    _(ac.samba).must_equal '[UX         ]'
    _(ac.intersect?(
        Yuzakan::Adapters::AdAdapter::AccountContorl::Flag::ACCOUNTDISABLE |
        Yuzakan::Adapters::AdAdapter::AccountContorl::Flag::LOCKOUT)).must_equal false
  end

  let 'enable' do
    ac.delete(Yuzakan::Adapters::AdAdapter::AccountContorl::Flag::ACCOUNTDISABLE)
    _(ac.flags).must_equal 0x10200
    _(ac.samba).must_equal '[UX         ]'
    _(ac.intersect?(
        Yuzakan::Adapters::AdAdapter::AccountContorl::Flag::ACCOUNTDISABLE |
        Yuzakan::Adapters::AdAdapter::AccountContorl::Flag::LOCKOUT)).must_equal false
  end

  it 'disable' do
    ac << Yuzakan::Adapters::AdAdapter::AccountContorl::Flag::ACCOUNTDISABLE
    _(ac.flags).must_equal 0x10202
    _(ac.samba).must_equal '[DUX        ]'
    _(ac.intersect?(
        Yuzakan::Adapters::AdAdapter::AccountContorl::Flag::ACCOUNTDISABLE |
        Yuzakan::Adapters::AdAdapter::AccountContorl::Flag::LOCKOUT)).must_equal true
  end

  describe 'disbaled user' do
    # ACCOUNTDISABLE 0x0002
    let(:flags) {
      Yuzakan::Adapters::AdAdapter::AccountContorl::DEFAULT_USER_FLAGS |
        Yuzakan::Adapters::AdAdapter::AccountContorl::Flag::ACCOUNTDISABLE
    }

    let 'user flags' do
      _(ac.flags).must_equal 0x10202
      _(ac.samba).must_equal '[DUX        ]'
      _(ac.intersect?(
          Yuzakan::Adapters::AdAdapter::AccountContorl::Flag::ACCOUNTDISABLE |
          Yuzakan::Adapters::AdAdapter::AccountContorl::Flag::LOCKOUT)).must_equal true
    end

    let 'enable' do
      ac.delete(Yuzakan::Adapters::AdAdapter::AccountContorl::Flag::ACCOUNTDISABLE)
      _(ac.flags).must_equal 0x10200
      _(ac.samba).must_equal '[UX         ]'
      _(ac.intersect?(
          Yuzakan::Adapters::AdAdapter::AccountContorl::Flag::ACCOUNTDISABLE |
          Yuzakan::Adapters::AdAdapter::AccountContorl::Flag::LOCKOUT)).must_equal false
    end

    it 'disable' do
      ac << Yuzakan::Adapters::AdAdapter::AccountContorl::Flag::ACCOUNTDISABLE
      _(ac.flags).must_equal 0x10202
      _(ac.samba).must_equal '[DUX        ]'
      _(ac.intersect?(
          Yuzakan::Adapters::AdAdapter::AccountContorl::Flag::ACCOUNTDISABLE |
          Yuzakan::Adapters::AdAdapter::AccountContorl::Flag::LOCKOUT)).must_equal true
    end
  end

  describe 'locked user' do
    let(:flags) {
      Yuzakan::Adapters::AdAdapter::AccountContorl::DEFAULT_USER_FLAGS |
        Yuzakan::Adapters::AdAdapter::AccountContorl::Flag::LOCKOUT
    }

    let 'user flags' do
      _(ac.flags).must_equal 0x10212
      _(ac.samba).must_equal '[LUX        ]'
      _(ac.intersect?(
          Yuzakan::Adapters::AdAdapter::AccountContorl::Flag::ACCOUNTDISABLE |
          Yuzakan::Adapters::AdAdapter::AccountContorl::Flag::LOCKOUT)).must_equal true
    end

    let 'enable' do
      ac.delete(Yuzakan::Adapters::AdAdapter::AccountContorl::Flag::ACCOUNTDISABLE)
      _(ac.flags).must_equal 0x10210
      _(ac.samba).must_equal '[LUX        ]'
      _(ac.intersect?(
          Yuzakan::Adapters::AdAdapter::AccountContorl::Flag::ACCOUNTDISABLE |
          Yuzakan::Adapters::AdAdapter::AccountContorl::Flag::LOCKOUT)).must_equal true
    end

    it 'disable' do
      ac << Yuzakan::Adapters::AdAdapter::AccountContorl::Flag::ACCOUNTDISABLE
      _(ac.flags).must_equal 0x10212
      _(ac.samba).must_equal '[DLUX       ]'
      _(ac.intersect?(
          Yuzakan::Adapters::AdAdapter::AccountContorl::Flag::ACCOUNTDISABLE |
          Yuzakan::Adapters::AdAdapter::AccountContorl::Flag::LOCKOUT)).must_equal true
    end
  end

  describe 'disabled and locked user' do
    let(:flags) {
      Yuzakan::Adapters::AdAdapter::AccountContorl::DEFAULT_USER_FLAGS |
        Yuzakan::Adapters::AdAdapter::AccountContorl::Flag::ACCOUNTDISABLE |
        Yuzakan::Adapters::AdAdapter::AccountContorl::Flag::LOCKOUT
    }

    let 'user flags' do
      _(ac.flags).must_equal 0x10212
      _(ac.samba).must_equal '[DLUX       ]'
      _(ac.intersect?(
          Yuzakan::Adapters::AdAdapter::AccountContorl::Flag::ACCOUNTDISABLE |
          Yuzakan::Adapters::AdAdapter::AccountContorl::Flag::LOCKOUT)).must_equal true
    end

    let 'enable' do
      ac.delete(Yuzakan::Adapters::AdAdapter::AccountContorl::Flag::ACCOUNTDISABLE)
      _(ac.flags).must_equal 0x10210
      _(ac.samba).must_equal '[LUX        ]'
      _(ac.intersect?(
          Yuzakan::Adapters::AdAdapter::AccountContorl::Flag::ACCOUNTDISABLE |
          Yuzakan::Adapters::AdAdapter::AccountContorl::Flag::LOCKOUT)).must_equal true
    end

    it 'disable' do
      ac << Yuzakan::Adapters::AdAdapter::AccountContorl::Flag::ACCOUNTDISABLE
      _(ac.flags).must_equal 0x10212
      _(ac.samba).must_equal '[DLUX       ]'
      _(ac.intersect?(
          Yuzakan::Adapters::AdAdapter::AccountContorl::Flag::ACCOUNTDISABLE |
          Yuzakan::Adapters::AdAdapter::AccountContorl::Flag::LOCKOUT)).must_equal true
    end
  end
end
