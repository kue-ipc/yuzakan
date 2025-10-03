# frozen_string_literal: true

RSpec.describe API::Actions::Attrs::Create do
  init_action_spec

  let(:action_opts) {
    {
      attr_repo: attr_repo,
      service_repo: service_repo,
    }
  }
  let(:action_params) {
    attr.to_h.except(:id).merge({
      mappings: [mapping.to_h],
    })
  }

  shared_examples "created" do
    it "is created" do
      response = action.call(params)
      expect(response).to be_successful
      expect(response.status).to eq 201
      expect(response.headers["Content-Type"]).to eq "application/json; charset=utf-8"
      expect(response.headers["Content-Location"]).to eq "/api/attrs/#{attr.name}"
      json = JSON.parse(response.body.first, symbolize_names: true)
      expect(json[:data]).to eq({
        **attr.to_h.except(:id),
        mappings: mappings.map { |mapping| mapping.to_h.except(:id) },
      })
    end
  end

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

    it_behaves_like "created"

    it "is created without order param" do
      response = action.call(params.except(:order))
      expect(response).to be_successful
      expect(response.status).to eq 201
      expect(response.headers["Content-Type"]).to eq "application/json; charset=utf-8"
      expect(response.headers["Content-Location"]).to eq "/api/attrs/#{attr.name}"
      json = JSON.parse(response.body.first, symbolize_names: true)
      expect(json[:data]).to eq({
        **attr.to_h.except(:id),
        mappings: mappings.map { |mapping| mapping.to_h.except(:id) },
      })
    end

    it "is failure with bad name pattern" do
      response = action.call({**params, name: "!"})
      expect(response).to be_client_error
      expect(response.status).to eq 422
      expect(response.headers["Content-Type"]).to eq "application/json; charset=utf-8"
      json = JSON.parse(response.body.first, symbolize_names: true)
      expect(json[:flash]).to eq({invalid: {name: ["名前付けの規則に違反しています。"]}})
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
        "0": {service: ["入力が必須です。"], key: ["存在しません。"]},
        "1": {service: ["存在しません。"], key: ["存在しません。"]},
      }}})
    end

    it "is failure without params" do
      response = action.call(env)
      expect(response).to be_client_error
      expect(response.status).to eq 422
      expect(response.headers["Content-Type"]).to eq "application/json; charset=utf-8"
      json = JSON.parse(response.body.first, symbolize_names: true)
      expect(json[:flash]).to eq({invalid: {name: ["存在しません。"], type: ["存在しません。"]}})
    end

    describe "existed name" do
      let(:attr_repository) { instance_double(AttrRepository, **attr_repository_stubs, exist_by_name?: true) }

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
        expect(json[:flash]).to eq({invalid: {name: ["名前付けの規則に違反しています。"]}})
      end
    end

    describe "not found service" do
      # service1のみない
      let(:services) {
        services_attributes
          .reject { |attributes| attributes[:name] == "service1" }
          .map { |attributes| Service.new(attributes) }
      }

      it "is failure" do
        response = action.call(params)
        expect(response).to be_client_error
        expect(response.status).to eq 422
        expect(response.headers["Content-Type"]).to eq "application/json; charset=utf-8"
        json = JSON.parse(response.body.first, symbolize_names: true)
        expect(json[:flash]).to eq({mappings: {"1": {service: ["見つかりません。"]}}})
      end
    end
  end
end
