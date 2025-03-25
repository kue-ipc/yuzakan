# frozen_string_literal: true

RSpec.describe Yuzakan::CryptOperation do
  subject(:decrypt) { Yuzakan::Operations::Decrypt.new(**params) }

  let(:encrypt) { Yuzakan::Operations::Encrypt.new(**params) }
  let(:params) { {} }
  let(:text) { "Ab01#日本語😺🀄等" }

  it "is successful" do
    result = encrypt.call(text)
    expect(result).to be_success
    expect(result.value!).to match(/\A[\x20-\x7E]*\z/)
    expect(result.value!.encoding).to eq Encoding::UTF_8

    result = decrypt.call(result.value!)
    expect(result).to be_success
    expect(result.value!.encoding).to eq Encoding::UTF_8
    expect(result.value!).to eq text
  end

  context "when empty text" do
    let(:text) { "" }

    it "is successful" do
      result = encrypt.call(text)
      expect(result).to be_success
      expect(result.value!).to match(/\A[\x20-\x7E]*\z/)
      expect(result.value!.encoding).to eq Encoding::UTF_8

      result = decrypt.call(result.value!)
      expect(result).to be_success
      expect(result.value!.encoding).to eq Encoding::UTF_8
      expect(result.value!).to eq text
    end
  end

  context "when long text" do
    let(:text) { "A" * 1024 * 1024 }

    it "is successful" do
      result = encrypt.call(text)
      expect(result).to be_success
      expect(result.value!).to match(/\A[\x20-\x7E]*\z/)
      expect(result.value!.encoding).to eq Encoding::UTF_8

      result = decrypt.call(result.value!)
      expect(result).to be_success
      expect(result.value!.encoding).to eq Encoding::UTF_8
      expect(result.value!).to eq text
    end
  end

  context "when use pbkdf2" do
    let(:params) do
      {
        settings: Yuzakan::Settings.new(
          session_secret: SecureRandom.hex(32),
          crypt_secret: SecureRandom.hex(32),
          crypt_kdf: "pbkdf2-hmac-sha256",
          crypt_cost: 600000),
      }
    end

    it "is successful" do
      result = encrypt.call(text)
      expect(result).to be_success
      expect(result.value!).to match(/\A[\x20-\x7E]*\z/)
      expect(result.value!.encoding).to eq Encoding::UTF_8

      result = decrypt.call(result.value!)
      expect(result).to be_success
      expect(result.value!.encoding).to eq Encoding::UTF_8
      expect(result.value!).to eq text
    end
  end
end
