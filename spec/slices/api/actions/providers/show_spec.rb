# frozen_string_literal: true

RSpec.describe API::Actions::Providers::Show do
  init_controller_spec
  let(:action_opts) { {provider_repository: provider_repository} }
  let(:format) { "application/json" }

  let(:action_params) { {id: "provider1"} }
  let(:provider_params) {
    {
      name: "provider1",
      display_name: "プロバイダー①",
      adapter: "test",
      order: 16,
      readable: true,
      writable: true,
      authenticatable: true,
      password_changeable: true,
      lockable: true,

      individual_password: false,
      self_management: false,
    }
  }
  let(:provider_params_attributes) {
    [
      {name: "str", value: Marshal.dump("hoge")},
      {name: "int", value: Marshal.dump(42)},
    ]
  }
  let(:provider_params_attributes_params) {
    {
      default: nil,
      str: "hoge",
      str_default: "デフォルト",
      str_fixed: "固定",
      str_required: nil,
      str_enc: nil,
      text: nil,
      int: 42,
      list: "default",
    }
  }
  let(:provider_with_params) { Provider.new(id: 3, **provider_params, provider_params: provider_params_attributes) }
  let(:provider_repository) { instance_double(ProviderRepository, find_with_params_by_name: provider_with_params) }

  it "is successful" do
    response = action.call(params)
    expect(response[0]).to eq 200
    expect(response[1]["Content-Type"]).to eq "#{format}; charset=utf-8"
    json = JSON.parse(response[2].first, symbolize_names: true)
    expect(json).to eq({
      **provider_params,
    })
  end

  describe "admin" do
    let(:user) { User.new(**user_attributes, clearance_level: 5) }
    let(:client) { "127.0.0.1" }

    it "is successful" do
      response = action.call(params)
      expect(response[0]).to eq 200
      expect(response[1]["Content-Type"]).to eq "#{format}; charset=utf-8"
      json = JSON.parse(response[2].first, symbolize_names: true)
      expect(json).to eq({
        **provider_params,
        params: provider_params_attributes_params,
      })
    end

    describe "not existed" do
      let(:provider_repository) {
        instance_double(ProviderRepository, find_with_params_by_name: nil)
      }

      it "is failure" do
        response = action.call(params)
        expect(response[0]).to eq 404
        expect(response[1]["Content-Type"]).to eq "#{format}; charset=utf-8"
        json = JSON.parse(response[2].first, symbolize_names: true)
        expect(json).to eq({
          code: 404,
          message: "Not Found",
        })
      end
    end
  end

  describe "no login session" do
    let(:session) { {uuid: uuid} }

    it "is error" do
      response = action.call(params)
      expect(response[0]).to eq 401
      expect(response[1]["Content-Type"]).to eq "#{format}; charset=utf-8"
      json = JSON.parse(response[2].first, symbolize_names: true)
      expect(json).to eq({code: 401, message: "Unauthorized"})
    end
  end
end
