# frozen_string_literal: true

RSpec.describe API::Actions::Attrs::Create do
  init_action_spec

  let(:action_opts) {
    allow(attr_repo).to receive_messages(exist?: false, last_order: 9999,
      create_with_mappings: attr, renumber_order: 0,
      get_with_mappings_and_services: attr)
    allow(attr_repo).to receive(:transaction).and_yield
    allow(service_repo).to receive_messages(all: [mapping.service])
    {
      attr_repo: attr_repo,
      service_repo: service_repo,
    }
  }

  let(:action_params) {
    {
      **struct_to_hash(attr, except: [:mappings]),
      mappings: [struct_to_hash(mapping, except: [:attr])],
    }
  }

  it_behaves_like "forbidden"

  context "when guest" do
    include_context "when guest"
    it_behaves_like "forbidden"
  end

  context "when observer" do
    include_context "when observer"
    it_behaves_like "forbidden"
  end

  context "when operator" do
    include_context "when operator"
    it_behaves_like "forbidden"
  end

  context "when administrator" do
    include_context "when administrator"
    it_behaves_like "forbidden"
  end

  context "when superuser" do
    include_context "when superuser"

    it "is created" do
      response = action.call(params)
      expect(response).to be_successful
      expect(response.status).to eq 201
      expect(response.headers["Content-Type"]).to eq "application/json; charset=utf-8"
      expect(response.headers["Content-Location"]).to eq "/api/attrs/#{attr.name}"
      json = JSON.parse(response.body.first, symbolize_names: true)
      expect(json[:data]).to eq({
        **struct_to_hash(attr, except: [:mappings]),
        mappings: attr.mappings.map { |mapping| struct_to_hash(mapping, except: [:attr]) },
      })
    end

    it "is created without order param" do
      response = action.call(params.except(:order))
      expect(response).to be_successful
      expect(response.status).to eq 201
      expect(response.headers["Content-Type"]).to eq "application/json; charset=utf-8"
      expect(response.headers["Content-Location"]).to eq "/api/attrs/#{attr.name}"
      json = JSON.parse(response.body.first, symbolize_names: true)
      expect(json[:data]).to eq({
        **struct_to_hash(attr, except: [:mappings]),
        mappings: attr.mappings.map { |mapping| struct_to_hash(mapping, except: [:attr]) },
      })
    end

    it "is created with minimum params" do
      response = action.call(params.except(:lable, :description, :order, :hidden, :readonly, :code, :mappings))
      expect(response).to be_successful
      expect(response.status).to eq 201
      expect(response.headers["Content-Type"]).to eq "application/json; charset=utf-8"
      expect(response.headers["Content-Location"]).to eq "/api/attrs/#{attr.name}"
      json = JSON.parse(response.body.first, symbolize_names: true)
      expect(json[:data]).to eq({
        **struct_to_hash(attr, except: [:mappings]),
        mappings: attr.mappings.map { |mapping| struct_to_hash(mapping, except: [:attr]) },
      })
    end

    it "is failure with bad name pattern" do
      response = action.call({**params, name: "!"})
      expect(response).to be_client_error
      expect(response.status).to eq 422
      expect(response.headers["Content-Type"]).to eq "application/json; charset=utf-8"
      json = JSON.parse(response.body.first, symbolize_names: true)
      expect(json[:flash]).to eq({invalid: {name: ["形式が間違っています。"]}})
    end

    it "is failure with name over" do
      response = action.call({**params, name: "a" * 256})
      expect(response).to be_client_error
      expect(response.status).to eq 422
      expect(response.headers["Content-Type"]).to eq "application/json; charset=utf-8"
      json = JSON.parse(response.body.first, symbolize_names: true)
      expect(json[:flash]).to eq({invalid: {name: ["サイズが255を超えてはいけません。"]}})
    end

    it "is failure with name number" do
      response = action.call({**params, name: 1})
      expect(response).to be_client_error
      expect(response.status).to eq 422
      expect(response.headers["Content-Type"]).to eq "application/json; charset=utf-8"
      json = JSON.parse(response.body.first, symbolize_names: true)
      expect(json[:flash]).to eq({invalid: {name: ["文字列を入力してください。"]}})
    end

    it "is failure with bad mapping params" do
      response = action.call({
        **params,
        mappings: [
          {service: "", name: "attr1_1", conversion: nil},
          {name: "attr1_2", conversion: "e2j"},
        ],
      })
      expect(response).to be_client_error
      expect(response.status).to eq 422
      expect(response.headers["Content-Type"]).to eq "application/json; charset=utf-8"
      json = JSON.parse(response.body.first, symbolize_names: true)
      expect(json[:flash]).to eq({invalid: {mappings: {
        "0": {service: ["入力が必須です。"], key: ["存在しません。"], type: ["存在しません。"]},
        "1": {service: ["存在しません。"], key: ["存在しません。"], type: ["存在しません。"]},
      }}})
    end

    it "is failure without params" do
      response = action.call(env)
      expect(response).to be_client_error
      expect(response.status).to eq 422
      expect(response.headers["Content-Type"]).to eq "application/json; charset=utf-8"
      json = JSON.parse(response.body.first, symbolize_names: true)
      expect(json[:flash]).to eq({invalid: {
        name: ["存在しません。"], category: ["存在しません。"], type: ["存在しません。"],
      }})
    end

    describe "when exist" do
      let(:action_opts) {
        allow(attr_repo).to receive_messages(exist?: true)
        {
          attr_repo: attr_repo,
          service_repo: service_repo,
        }
      }

      it "is failure" do
        response = action.call(params)
        expect(response.status).to eq 422
        expect(response.headers["Content-Type"]).to eq "application/json; charset=utf-8"
        json = JSON.parse(response.body.first, symbolize_names: true)
        expect(json[:flash]).to eq({invalid: {name: ["重複しています。"]}})
      end

      it "is failure with bad name pattern" do
        response = action.call({**params, name: "!"})
        expect(response).to be_client_error
        expect(response.status).to eq 422
        expect(response.headers["Content-Type"]).to eq "application/json; charset=utf-8"
        json = JSON.parse(response.body.first, symbolize_names: true)
        expect(json[:flash]).to eq({invalid: {name: ["形式が間違っています。"]}})
      end
    end

    describe "not found service" do
      # サービス一覧が異なるので見つからなくなる。
      let(:action_opts) {
        allow(attr_repo).to receive_messages(exist?: false)
        allow(service_repo).to receive_messages(all: [service])
        {
          attr_repo: attr_repo,
          service_repo: service_repo,
        }
      }

      it "is failure" do
        response = action.call(params)
        expect(response).to be_client_error
        expect(response.status).to eq 422
        expect(response.headers["Content-Type"]).to eq "application/json; charset=utf-8"
        json = JSON.parse(response.body.first, symbolize_names: true)
        expect(json[:flash]).to eq({invalid: {mappings: {"0": {service: ["見つかりません。"]}}}})
      end
    end
  end
end
