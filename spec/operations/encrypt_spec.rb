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

  context "when empty data" do
    let(:data) { "" }

    it "is successful" do
      result = subject.call(data)
      expect(result).to be_success
      expect(result.value!).to match(/\A[\x20-\x7E]*\z/)
      expect(result.value!).not_to eq data
      expect(result.value!.encoding).to eq Encoding::UTF_8
    end
  end

  context "when long data" do
    let(:data) { "A" * 1024 * 1024 }

    it "is successful" do
      result = subject.call(data)
      expect(result).to be_success
      expect(result.value!).to match(/\A[\x20-\x7E]*\z/)
      expect(result.value!).not_to eq data
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

    it "is successful" do
      result = subject.call(data)
      expect(result).to be_success
      expect(result.value!).to match(/\A[\x20-\x7E]*\z/)
      expect(result.value!).not_to eq data
      expect(result.value!.encoding).to eq Encoding::UTF_8
    end
  end
end
