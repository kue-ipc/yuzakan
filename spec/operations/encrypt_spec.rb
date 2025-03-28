# frozen_string_literal: true

RSpec.describe Yuzakan::Operations::Encrypt do
  subject(:operation) { described_class.new(**params) }

  let(:params) { {} }
  let(:data) { "Ab01#日本語😺🀄等" }

  it "is successful" do
    result = subject.call(data)
    expect(result).to be_success
    expect(result.value!).to match(/\A[\x20-\x7E]*\z/)
    expect(result.value!).not_to eq data
    expect(result.value!.encoding).to eq Encoding::UTF_8
  end

  describe "empty data" do
    let(:data) { "" }

    it "is successful" do
      result = subject.call(data)
      expect(result).to be_success
      expect(result.value!).to match(/\A[\x20-\x7E]*\z/)
      expect(result.value!).not_to eq data
      expect(result.value!.encoding).to eq Encoding::UTF_8
    end
  end

  describe "long data" do
    let(:data) { "A" * 1024 * 1024 }

    it "is successful" do
      result = subject.call(data)
      expect(result).to be_success
      expect(result.value!).to match(/\A[\x20-\x7E]*\z/)
      expect(result.value!).not_to eq data
      expect(result.value!.encoding).to eq Encoding::UTF_8
    end
  end

  describe "binary data" do
    let(:data) { [*(0..255).to_a, 0, *(255..0).to_a].pack("C*") }

    it "is successful" do
      result = subject.call(data, bin: true)
      expect(result).to be_success
      expect(result.value!).not_to eq data
      expect(result.value!.encoding).to eq Encoding::ASCII_8BIT
    end
  end

  context "when use aes-128-cbc" do
    let(:params) {
      {
        settings: Yuzakan::Settings.new(**Hanami.app["settings"].to_h,
          crypt_algorithm: "aes-128-cbc"),
      }
    }

    it "is successful" do
      result = subject.call(data)
      expect(result).to be_success
      expect(result.value!).to match(/\A[\x20-\x7E]*\z/)
      expect(result.value!).not_to eq data
      expect(result.value!.encoding).to eq Encoding::UTF_8
    end
  end

  context "when use pbkdf2" do
    let(:params) {
      {
        settings: Yuzakan::Settings.new(**Hanami.app["settings"].to_h,
          crypt_kdf: "pbkdf2-hmac-sha256", crypt_cost: 600000),
      }
    }

    it "is successful" do
      result = subject.call(data)
      expect(result).to be_success
      expect(result.value!).to match(/\A[\x20-\x7E]*\z/)
      expect(result.value!).not_to eq data
      expect(result.value!.encoding).to eq Encoding::UTF_8
    end
  end
end
