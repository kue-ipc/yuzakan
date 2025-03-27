# frozen_string_literal: true

RSpec.describe Yuzakan::Operations::GeneratePassword do
  subject(:operation) { described_class.new(**params) }

  let(:params) { {config_repo: config_repo} }
  let(:config_repo) {
    instance_double(Yuzakan::Repos::ConfigRepo, current: config)
  }
  let(:config) { Factory.structs[:config] }

  it "is successful" do
    result = subject.call
    expect(result).to be_success
    expect(result.value!).to match(/\A[\x20-\x7E]+\z/)
    expect(result.value!.size).to eq 24
    expect(result.value!.encoding).to eq Encoding::UTF_8
  end

  context "when alphanumeric type" do
    let(:config) {
      Factory.structs[:config, generate_password_type: "alphanumeric"]
    }

    it "is successful" do
      result = subject.call
      expect(result).to be_success
      expect(result.value!).to match(/\A[\w&&[^_]]+\z/)
      expect(result.value!.size).to eq 24
      expect(result.value!.encoding).to eq Encoding::UTF_8
    end
  end

  context "when 8 size" do
    let(:config) { Factory.structs[:config, generate_password_size: 8] }

    it "is successful" do
      result = subject.call
      expect(result).to be_success
      expect(result.value!).to match(/\A[\x20-\x7E]+\z/)
      expect(result.value!.size).to eq 8
      expect(result.value!.encoding).to eq Encoding::UTF_8
    end
  end

  context "when more exclude chars" do
    let(:config) {
      Factory.structs[:config, generate_password_chars:
        ((0x20..0x7e).map(&:chr) - ["!", "1", "A", "a"]).join]
    }

    it "is successful" do
      result = subject.call
      expect(result).to be_success
      expect(result.value!).to match(/\A[!1Aa]+\z/)
      expect(result.value!.size).to eq 24
      expect(result.value!.encoding).to eq Encoding::UTF_8
    end
  end

  context "when custom" do
    let(:config) {
      Factory.structs[:config, generate_password_type: "custom",
        generate_password_chars: "!1Aa"]
    }

    it "is successful" do
      result = subject.call
      expect(result).to be_success
      expect(result.value!).to match(/\A[!1Aa]+\z/)
      expect(result.value!.size).to eq 24
      expect(result.value!.encoding).to eq Encoding::UTF_8
    end
  end

  context "when exclude all chars" do
    let(:config) {
      Factory.structs[:config, generate_password_chars: (0x20..0x7e).map(&:chr).join]
    }

    it "is failed" do
      result = subject.call
      expect(result).to be_failure
      expect(result.failure).to eq [:invalid, {char_list: [:filled?]}]
    end
  end

  context "when 0 size" do
    let(:config) { Factory.structs[:config, generate_password_size: 0] }

    it "is failed" do
      result = subject.call
      expect(result).to be_failure
      expect(result.failure).to eq [:invalid, {size: [gt?: 0]}]
    end
  end

  context "when unknown type" do
    let(:config) { Factory.structs[:config, generate_password_type: "unknown"] }

    it "is failed" do
      result = subject.call
      expect(result).to be_failure
      expect(result.failure).to eq [:invalid, {type: [:included_in?]}]
    end
  end
end
