# frozen_string_literal: true

RSpec.describe Yuzakan::Operations::Decrypt do
  subject(:operation) { described_class.new(**params) }

  let(:params) { {} }
  let(:data) { encrypt.call(plain).value! }
  let(:encrypt) { Yuzakan::Operations::Encrypt.new }
  let(:plain) { "Ab01#日本語😺🀄等" }

  it "is successful" do
    result = subject.call(data)
    expect(result).to be_success
    expect(result.value!).to eq plain
    expect(result.value!.encoding).to eq Encoding::UTF_8
  end

  describe "empty data" do
    let(:plain) { "" }

    it "is successful" do
      result = subject.call(data)
      expect(result).to be_success
      expect(result.value!).to eq plain
      expect(result.value!.encoding).to eq Encoding::UTF_8
    end
  end

  describe "long data" do
    let(:plain) { "A" * 1024 * 1024 }

    it "is successful" do
      result = subject.call(data)
      expect(result).to be_success
      expect(result.value!).to eq plain
      expect(result.value!.encoding).to eq Encoding::UTF_8
    end
  end

  describe "binary data" do
    let(:plain) { [*(0..255).to_a, 0, *(255..0).to_a].pack("C*") }
    let(:data) { encrypt.call(plain, bin: true).value! }

    it "is successful" do
      result = subject.call(data, bin: true)
      expect(result).to be_success
      expect(result.value!).to eq plain
      expect(result.value!.encoding).to eq Encoding::ASCII_8BIT
    end
  end

  context "when wrong crypt secret" do
    let(:params) do
      {
        settings: Yuzakan::Settings.new(**Hanami.app["settings"].to_h,
          crypt_secret: "hoge"),
      }
    end

    it "is failed" do
      result = subject.call(data)
      expect(result).to be_failure
      expect(result.failure).to be_a Array
      expect(result.failure.length).to eq 2
      expect(result.failure.first).to eq :error
      expect(result.failure.last).to be_a OpenSSL::Cipher::CipherError
    end
  end

  context "when use aes-128-cbc" do
    let(:params) do
      {
        settings: Yuzakan::Settings.new(**Hanami.app["settings"].to_h,
          crypt_algorithm: "aes-128-cbc"),
      }
    end
    let(:encrypt) { Yuzakan::Operations::Encrypt.new(**params) }

    it "is successful" do
      result = subject.call(data)
      expect(result).to be_success
      expect(result.value!).to eq plain
      expect(result.value!.encoding).to eq Encoding::UTF_8
    end
  end

  context "when use pbkdf2" do
    let(:params) do
      {
        settings: Yuzakan::Settings.new(**Hanami.app["settings"].to_h,
          crypt_kdf: "pbkdf2-hmac-sha256", crypt_cost: 600000),
      }
    end
    let(:encrypt) { Yuzakan::Operations::Encrypt.new(**params) }

    it "is successful" do
      result = subject.call(data)
      expect(result).to be_success
      expect(result.value!).to eq plain
      expect(result.value!.encoding).to eq Encoding::UTF_8
    end
  end
end
