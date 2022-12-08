require_relative '../../../spec_helper'

describe Yuzakan::Adapters::AdAdapter::AccountControl do
  let(:ac) { Yuzakan::Adapters::AdAdapter::AccountControl.new(flags) }
  let(:flags) { Yuzakan::Adapters::AdAdapter::AccountControl::DEFAULT_USER_FLAGS }

  it 'user flags' do
    # NORMAL_ACCOUNT (0x0200) | DONT_EXPIRE_PASSWORD (0x10000)
    _(ac.to_i).must_equal 0x10200
    _(ac.accountdisable).must_equal false
    _(ac.accountdisable?).must_equal false
    _(ac.intersect?(Yuzakan::Adapters::AdAdapter::AccountControl::LOCKED_FLAGS)).must_equal false
  end

  it 'enable' do
    ac.accountdisable = false
    _(ac.to_i).must_equal 0x10200
    _(ac.accountdisable).must_equal false
    _(ac.accountdisable?).must_equal false
    _(ac.intersect?(Yuzakan::Adapters::AdAdapter::AccountControl::LOCKED_FLAGS)).must_equal false
  end

  it 'disable' do
    ac.accountdisable = true
    _(ac.to_i).must_equal 0x10202
    _(ac.accountdisable).must_equal true
    _(ac.accountdisable?).must_equal true
    _(ac.intersect?(Yuzakan::Adapters::AdAdapter::AccountControl::LOCKED_FLAGS)).must_equal true
  end

  it 'new array' do
    array_ac = Yuzakan::Adapters::AdAdapter::AccountControl.new(
      [
        Yuzakan::Adapters::AdAdapter::AccountControl::Flag::NORMAL_ACCOUNT,
        Yuzakan::Adapters::AdAdapter::AccountControl::Flag::DONT_EXPIRE_PASSWORD,
      ])
    _(array_ac == ac).must_equal true
  end

  it 'set PASSWORD_EXPIRED' do
    _(ac.password_expired).must_equal false
    ac.password_expired = true
    _(ac.to_i).must_equal 0x810200
    _(ac.password_expired).must_equal true
    _(ac.password_expired?).must_equal true
  end

  describe 'disbaled user' do
    # ACCOUNTDISABLE 0x0002
    let(:flags) {
      Yuzakan::Adapters::AdAdapter::AccountControl::DEFAULT_USER_FLAGS |
        Yuzakan::Adapters::AdAdapter::AccountControl::Flag::ACCOUNTDISABLE
    }

    it 'user flags' do
      _(ac.to_i).must_equal 0x10202
      _(ac.accountdisable).must_equal true
      _(ac.accountdisable?).must_equal true
      _(ac.intersect?(Yuzakan::Adapters::AdAdapter::AccountControl::LOCKED_FLAGS)).must_equal true
    end

    it 'enable' do
      ac.accountdisable = false
      _(ac.to_i).must_equal 0x10200
      _(ac.accountdisable).must_equal false
      _(ac.accountdisable?).must_equal false
      _(ac.intersect?(Yuzakan::Adapters::AdAdapter::AccountControl::LOCKED_FLAGS)).must_equal false
    end

    it 'disable' do
      ac.accountdisable = true
      _(ac.to_i).must_equal 0x10202
      _(ac.accountdisable).must_equal true
      _(ac.accountdisable?).must_equal true
      _(ac.intersect?(Yuzakan::Adapters::AdAdapter::AccountControl::LOCKED_FLAGS)).must_equal true
    end
  end

  describe 'locked user' do
    let(:flags) {
      Yuzakan::Adapters::AdAdapter::AccountControl::DEFAULT_USER_FLAGS |
        Yuzakan::Adapters::AdAdapter::AccountControl::Flag::LOCKOUT
    }

    it 'user flags' do
      _(ac.to_i).must_equal 0x10210
      _(ac.accountdisable).must_equal false
      _(ac.accountdisable?).must_equal false
      _(ac.intersect?(Yuzakan::Adapters::AdAdapter::AccountControl::LOCKED_FLAGS)).must_equal true
    end

    it 'enable' do
      ac.accountdisable = false
      _(ac.to_i).must_equal 0x10210
      _(ac.accountdisable).must_equal false
      _(ac.accountdisable?).must_equal false
      _(ac.intersect?(Yuzakan::Adapters::AdAdapter::AccountControl::LOCKED_FLAGS)).must_equal true
    end

    it 'disable' do
      ac.accountdisable = true
      _(ac.to_i).must_equal 0x10212
      _(ac.accountdisable).must_equal true
      _(ac.accountdisable?).must_equal true
      _(ac.intersect?(Yuzakan::Adapters::AdAdapter::AccountControl::LOCKED_FLAGS)).must_equal true
    end
  end

  describe 'disabled and locked user' do
    let(:flags) {
      Yuzakan::Adapters::AdAdapter::AccountControl::DEFAULT_USER_FLAGS |
        Yuzakan::Adapters::AdAdapter::AccountControl::Flag::ACCOUNTDISABLE |
        Yuzakan::Adapters::AdAdapter::AccountControl::Flag::LOCKOUT
    }

    it 'user flags' do
      _(ac.to_i).must_equal 0x10212
      _(ac.accountdisable).must_equal true
      _(ac.accountdisable?).must_equal true
      _(ac.intersect?(Yuzakan::Adapters::AdAdapter::AccountControl::LOCKED_FLAGS)).must_equal true
    end

    it 'enable' do
      ac.accountdisable = false
      _(ac.to_i).must_equal 0x10210
      _(ac.accountdisable).must_equal false
      _(ac.accountdisable?).must_equal false
      _(ac.intersect?(Yuzakan::Adapters::AdAdapter::AccountControl::LOCKED_FLAGS)).must_equal true
    end

    it 'disable' do
      ac.accountdisable = true
      _(ac.to_i).must_equal 0x10212
      _(ac.accountdisable).must_equal true
      _(ac.accountdisable?).must_equal true
      _(ac.intersect?(Yuzakan::Adapters::AdAdapter::AccountControl::LOCKED_FLAGS)).must_equal true
    end
  end
end
