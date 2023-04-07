# frozen_string_literal: true

RSpec.describe Yuzakan::Adapters::AdAdapter::AccountControl do
  let(:ac) { Yuzakan::Adapters::AdAdapter::AccountControl.new(flags) }
  let(:flags) { Yuzakan::Adapters::AdAdapter::AccountControl::DEFAULT_USER_FLAGS }

  it 'user flags' do
    # NORMAL_ACCOUNT (0x0200) | DONT_EXPIRE_PASSWORD (0x10000)
    expect(ac.to_i).to eq 0x10200
    expect(ac.accountdisable).to eq false
    expect(ac.accountdisable?).to eq false
  end

  it 'enable' do
    ac.accountdisable = false
    expect(ac.to_i).to eq 0x10200
    expect(ac.accountdisable).to eq false
    expect(ac.accountdisable?).to eq false
  end

  it 'disable' do
    ac.accountdisable = true
    expect(ac.to_i).to eq 0x10202
    expect(ac.accountdisable).to eq true
    expect(ac.accountdisable?).to eq true
  end

  it 'new array' do
    array_ac = Yuzakan::Adapters::AdAdapter::AccountControl.new(
      [
        Yuzakan::Adapters::AdAdapter::AccountControl::Flag::NORMAL_ACCOUNT,
        Yuzakan::Adapters::AdAdapter::AccountControl::Flag::DONT_EXPIRE_PASSWORD,
      ])
    expect(array_ac == ac).to eq true
  end

  it 'set PASSWORD_EXPIRED' do
    expect(ac.password_expired).to eq false
    ac.password_expired = true
    expect(ac.to_i).to eq 0x810200
    expect(ac.password_expired).to eq true
    expect(ac.password_expired?).to eq true
  end

  describe 'disbaled user' do
    # ACCOUNTDISABLE 0x0002
    let(:flags) {
      Yuzakan::Adapters::AdAdapter::AccountControl::DEFAULT_USER_FLAGS |
        Yuzakan::Adapters::AdAdapter::AccountControl::Flag::ACCOUNTDISABLE
    }

    it 'user flags' do
      expect(ac.to_i).to eq 0x10202
      expect(ac.accountdisable).to eq true
      expect(ac.accountdisable?).to eq true
    end

    it 'enable' do
      ac.accountdisable = false
      expect(ac.to_i).to eq 0x10200
      expect(ac.accountdisable).to eq false
      expect(ac.accountdisable?).to eq false
    end

    it 'disable' do
      ac.accountdisable = true
      expect(ac.to_i).to eq 0x10202
      expect(ac.accountdisable).to eq true
      expect(ac.accountdisable?).to eq true
    end
  end
end
