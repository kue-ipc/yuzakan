# frozen_string_literal: true

RSpec.describe Yuzakan::Operations::GeneratePassword, :db do
  subject(:operation) { described_class.new(**params) }

  let(:params) { {config_repo: config_repo} }
  let(:config_repo) do
    instance_double(Yuzakan::Repos::ConfigRepo, {current: config})
  end
  let(:config) { Factory[:config] }

  it "is successful" do
    result = subject.call
    expect(result).to be_success
    expect(result.value!).to match(/\A[\x20-\x7E]+\z/)
    expect(result.value!.encoding).to eq Encoding::UTF_8
  end
end
