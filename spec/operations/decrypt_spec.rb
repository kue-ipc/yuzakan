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
end
