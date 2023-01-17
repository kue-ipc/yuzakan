# frozen_string_literal: true

RSpec.describe Provider do
  let(:attributes) {
    {
      name: 'test',
      dispaly_name: 'テスト',
      adapter_name: 'test',
      order: 0,
      readable: true,
      writable: true,
      authenticatable: true,
      password_changeable: true,
      individual_password: false,
      lockable: true,
      self_management: false,
      provider_params: provider_params,
    }
  }

  let(:provider_params) {
    [
      {
        name: 'str',
        value: Marshal.dump('文字列'),
      },
    ]
  }

  it 'test adapter provider' do
    provider = Provider.new(**attributes)
    expect(provider.name).to eq 'test'
    expect(provider.params[:str]).to eq '文字列'
  end
end
