# frozen_string_literal: true

require_relative '../../../spec_helper'

RSpec.describe Yuzakan::Adapters::AdAdapter::AccountControl do
  let(:ac) { Yuzakan::Adapters::AdAdapter::AccountControl.new(flags) }
  let(:flags) { Yuzakan::Adapters::AdAdapter::AccountControl::DEFAULT_USER_FLAGS }

  it 'user flags' do
    # NORMAL_ACCOUNT (0x0200) | DONT_EXPIRE_PASSWORD (0x10000)
    expect(ac.to_i).must_equal 0x10200
    expect(ac.accountdisable).must_equal false
    expect(ac.accountdisable?).must_equal false
    expect(ac.intersect?(Yuzakan::Adapters::AdAdapter::AccountControl::LOCKED_FLAGS)).must_equal false
  end

  it 'enable' do
    ac.accountdisable = false
    expect(ac.to_i).must_equal 0x10200
    expect(ac.accountdisable).must_equal false
    expect(ac.accountdisable?).must_equal false
    expect(ac.intersect?(Yuzakan::Adapters::AdAdapter::AccountControl::LOCKED_FLAGS)).must_equal false
  end

  it 'disable' do
    ac.accountdisable = true
    expect(ac.to_i).must_equal 0x10202
    expect(ac.accountdisable).must_equal true
    expect(ac.accountdisable?).must_equal true
    expect(ac.intersect?(Yuzakan::Adapters::AdAdapter::AccountControl::LOCKED_FLAGS)).must_equal true
  end

  it 'new array' do
    array_ac = Yuzakan::Adapters::AdAdapter::AccountControl.new(
      [
        Yuzakan::Adapters::AdAdapter::AccountControl::Flag::NORMAL_ACCOUNT,
        Yuzakan::Adapters::AdAdapter::AccountControl::Flag::DONT_EXPIRE_PASSWORD,
      ])
    expect(array_ac == ac).must_equal true
  end

  it 'set PASSWORD_EXPIRED' do
    expect(ac.password_expired).must_equal false
    ac.password_expired = true
    expect(ac.to_i).must_equal 0x810200
    expect(ac.password_expired).must_equal true
    expect(ac.password_expired?).must_equal true
  end

  describe 'disbaled user' do
    # ACCOUNTDISABLE 0x0002
    let(:flags) {
      Yuzakan::Adapters::AdAdapter::AccountControl::DEFAULT_USER_FLAGS |
        Yuzakan::Adapters::AdAdapter::AccountControl::Flag::ACCOUNTDISABLE
    }

    it 'user flags' do
      expect(ac.to_i).must_equal 0x10202
      expect(ac.accountdisable).must_equal true
      expect(ac.accountdisable?).must_equal true
      expect(ac.intersect?(Yuzakan::Adapters::AdAdapter::AccountControl::LOCKED_FLAGS)).must_equal true
    end

    it 'enable' do
      ac.accountdisable = false
      expect(ac.to_i).must_equal 0x10200
      expect(ac.accountdisable).must_equal false
      expect(ac.accountdisable?).must_equal false
      expect(ac.intersect?(Yuzakan::Adapters::AdAdapter::AccountControl::LOCKED_FLAGS)).must_equal false
    end

    it 'disable' do
      ac.accountdisable = true
      expect(ac.to_i).must_equal 0x10202
      expect(ac.accountdisable).must_equal true
      expect(ac.accountdisable?).must_equal true
      expect(ac.intersect?(Yuzakan::Adapters::AdAdapter::AccountControl::LOCKED_FLAGS)).must_equal true
    end
  end

  describe 'locked user' do
    let(:flags) {
      Yuzakan::Adapters::AdAdapter::AccountControl::DEFAULT_USER_FLAGS |
        Yuzakan::Adapters::AdAdapter::AccountControl::Flag::LOCKOUT
    }

    it 'user flags' do
      expect(ac.to_i).must_equal 0x10210
      expect(ac.accountdisable).must_equal false
      expect(ac.accountdisable?).must_equal false
      expect(ac.intersect?(Yuzakan::Adapters::AdAdapter::AccountControl::LOCKED_FLAGS)).must_equal true
    end

    it 'enable' do
      ac.accountdisable = false
      expect(ac.to_i).must_equal 0x10210
      expect(ac.accountdisable).must_equal false
      expect(ac.accountdisable?).must_equal false
      expect(ac.intersect?(Yuzakan::Adapters::AdAdapter::AccountControl::LOCKED_FLAGS)).must_equal true
    end

    it 'disable' do
      ac.accountdisable = true
      expect(ac.to_i).must_equal 0x10212
      expect(ac.accountdisable).must_equal true
      expect(ac.accountdisable?).must_equal true
      expect(ac.intersect?(Yuzakan::Adapters::AdAdapter::AccountControl::LOCKED_FLAGS)).must_equal true
    end
  end

  describe 'disabled and locked user' do
    let(:flags) {
      Yuzakan::Adapters::AdAdapter::AccountControl::DEFAULT_USER_FLAGS |
        Yuzakan::Adapters::AdAdapter::AccountControl::Flag::ACCOUNTDISABLE |
        Yuzakan::Adapters::AdAdapter::AccountControl::Flag::LOCKOUT
    }

    it 'user flags' do
      expect(ac.to_i).must_equal 0x10212
      expect(ac.accountdisable).must_equal true
      expect(ac.accountdisable?).must_equal true
      expect(ac.intersect?(Yuzakan::Adapters::AdAdapter::AccountControl::LOCKED_FLAGS)).must_equal true
    end

    it 'enable' do
      ac.accountdisable = false
      expect(ac.to_i).must_equal 0x10210
      expect(ac.accountdisable).must_equal false
      expect(ac.accountdisable?).must_equal false
      expect(ac.intersect?(Yuzakan::Adapters::AdAdapter::AccountControl::LOCKED_FLAGS)).must_equal true
    end

    it 'disable' do
      ac.accountdisable = true
      expect(ac.to_i).must_equal 0x10212
      expect(ac.accountdisable).must_equal true
      expect(ac.accountdisable?).must_equal true
      expect(ac.intersect?(Yuzakan::Adapters::AdAdapter::AccountControl::LOCKED_FLAGS)).must_equal true
    end
  end
end
