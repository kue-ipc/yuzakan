# frozen_string_literal: true

RSpec.describe API::Actions::Services::Create do
  init_action_spec
  let(:action_opts) { {service_repository: service_repository} }
  let(:format) { "application/json" }
  let(:action_params) { {**adapter_params, params: adapter_params_params} }

  let(:adapter_params) {
    {
      name: "service1",
      label: "プロバイダー①",
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

  let(:adapter_params_params) {
    {
      str: "hoge",
      str_required: "fuga",
      str_enc: "piyo",
      text: "moe",
      int: 42,
      list: "other",
    }
  }
  let(:adapter_params_attributes) {
    [
      {name: "str", value: Marshal.dump("hoge")},
      {name: "int", value: Marshal.dump(42)},
    ]
  }
  let(:adapter_params_attributes_params) {
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
  let(:service_without_params) { Service.new(id: 3, **adapter_params) }
  let(:service_with_params) { Service.new(id: 3, **adapter_params, adapter_params: adapter_params_attributes) }
  let(:service_repository) {
    instance_double(ServiceRepository,
      exist_by_name?: false,
      last_order: 16,
      create: service_without_params,
      find_with_params: service_with_params,
      find_with_params_by_name: service_with_params,
      add_param: AdapterParam.new)
  }

  it "is failure" do
    response = action.call(params)
    expect(response.status).to eq 403
    expect(response.headers["Content-Type"]).to eq "application/json; charset=utf-8"
    json = JSON.parse(response.body.first, symbolize_names: true)
    expect(json).to eq({code: 403, message: "Forbidden"})
  end

  describe "admin" do
    let(:user) { User.new(**user_attributes, clearance_level: 5) }
    let(:client) { "127.0.0.1" }

    it "is successful" do
      response = action.call(params)
      expect(response.status).to eq 201
      expect(response.headers["Content-Type"]).to eq "application/json; charset=utf-8"
      expect(response.headers["Content-Location"]).to eq "/api/services/#{service_with_params.name}"
      json = JSON.parse(response.body.first, symbolize_names: true)
      expect(json).to eq({
        **adapter_params,
        params: adapter_params_attributes_params,
      })
    end

    it "is successful without order param" do
      response = action.call(params.except(:order))
      expect(response.status).to eq 201
      expect(response.headers["Content-Type"]).to eq "application/json; charset=utf-8"
      expect(response.headers["Content-Location"]).to eq "/api/services/#{service_with_params.name}"
      json = JSON.parse(response.body.first, symbolize_names: true)
      expect(json).to eq({
        **adapter_params,
        params: adapter_params_attributes_params,
      })
    end

    it "is failure with bad name pattern" do
      response = action.call({**params, name: "!"})
      expect(response.status).to eq 400
      expect(response.headers["Content-Type"]).to eq "application/json; charset=utf-8"
      json = JSON.parse(response.body.first, symbolize_names: true)
      expect(json).to eq({
        code: 400,
        message: "Bad Request",
        errors: [{name: ["名前付けの規則に違反しています。"]}],
      })
    end

    it "is failure with name over" do
      response = action.call({**params, name: "a" * 256})
      expect(response.status).to eq 400
      expect(response.headers["Content-Type"]).to eq "application/json; charset=utf-8"
      json = JSON.parse(response.body.first, symbolize_names: true)
      expect(json).to eq({
        code: 400,
        message: "Bad Request",
        errors: [{name: ["サイズが255を超えてはいけません。"]}],
      })
    end

    it "is failure with name number" do
      response = action.call({**params, name: 1})
      expect(response.status).to eq 400
      expect(response.headers["Content-Type"]).to eq "application/json; charset=utf-8"
      json = JSON.parse(response.body.first, symbolize_names: true)
      expect(json).to eq({
        code: 400,
        message: "Bad Request",
        errors: [{name: ["文字列を入力してください。"]}],
      })
    end

    it "is failure with bad adapter_params params" do
      response = action.call({
        **params,
        params: "abc",
      })
      expect(response.status).to eq 400
      expect(response.headers["Content-Type"]).to eq "application/json; charset=utf-8"
      json = JSON.parse(response.body.first, symbolize_names: true)
      expect(json).to eq({
        code: 400,
        message: "Bad Request",
        errors: [{
          params: ["連想配列を入力してください。"],
        }],
      })
    end

    it "is failure without params" do
      response = action.call(env)
      expect(response.status).to eq 400
      expect(response.headers["Content-Type"]).to eq "application/json; charset=utf-8"
      json = JSON.parse(response.body.first, symbolize_names: true)
      expect(json).to eq({
        code: 400,
        message: "Bad Request",
        errors: [{name: ["存在しません。"], adapter: ["存在しません。"]}],
      })
    end

    describe "existed name" do
      let(:service_repository) {
        instance_double(ServiceRepository,
          exist_by_name?: true,
          last_order: 16,
          create: service_without_params,
          find_with_params: service_with_params,
          add_param: AdapterParam.new)
      }

      it "is failure" do
        response = action.call(params)
        expect(response.status).to eq 422
        expect(response.headers["Content-Type"]).to eq "application/json; charset=utf-8"
        json = JSON.parse(response.body.first, symbolize_names: true)
        expect(json).to eq({
          code: 422,
          message: "Unprocessable Entity",
          errors: [{name: ["重複しています。"]}],
        })
      end

      it "is failure with bad name pattern" do
        response = action.call({**params, name: "!"})
        expect(response.status).to eq 400
        expect(response.headers["Content-Type"]).to eq "application/json; charset=utf-8"
        json = JSON.parse(response.body.first, symbolize_names: true)
        expect(json).to eq({
          code: 400,
          message: "Bad Request",
          errors: [{name: ["名前付けの規則に違反しています。"]}],
        })
      end
    end
  end

  describe "no login session" do
    let(:session) { {uuid: uuid} }

    it "is error" do
      response = action.call(params)
      expect(response.status).to eq 401
      expect(response.headers["Content-Type"]).to eq "application/json; charset=utf-8"
      json = JSON.parse(response.body.first, symbolize_names: true)
      expect(json).to eq({code: 401, message: "Unauthorized"})
    end
  end
end
