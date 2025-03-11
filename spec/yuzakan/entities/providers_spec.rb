# frozen_string_literal: true

RSpec.describe Provider do
  let(:attributes) {
    {
      name: "test",
      dispaly_name: "テスト",
      adapter: "test",
      order: 0,
      readable: true,
      writable: true,
      authenticatable: true,
      password_changeable: true,
      individual_password: false,
      lockable: true,
      self_management: false,
      adapter_params: adapter_params,
    }
  }

  let(:adapter_params) {
    [
      {
        name: "str",
        value: Marshal.dump("文字列"),
      },
    ]
  }

  it "test adapter provider" do
    provider = described_class.new(**attributes)
    expect(provider.name).to eq "test"
    expect(provider.params[:str]).to eq "文字列"
  end
end
