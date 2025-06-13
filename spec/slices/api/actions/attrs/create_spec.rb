# frozen_string_literal: true

RSpec.describe API::Actions::Attrs::Create do
  init_action_spec

  let(:action_opts) {
    {
      attr_repo: attr_repo,
      provider_repo: provider_repo,
    }
  }
  let(:action_params) {
    {
      **attr.to_h.except(:id),
      mappings: mappings.to_h,
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

    it "is successful" do
      response = action.call(params)
      expect(response.status).to eq 201
      expect(response.headers["Content-Type"]).to eq "application/json; charset=utf-8"
      expect(response.headers["Content-Location"]).to eq "/api/attrs/#{attr.name}"

      json = JSON.parse(response.body.first, symbolize_names: true)
      expect(json["data"]).to eq({
        **attr_attributes.except(:id),
        mappings: mappings.to_h,
      })
    end

    it "is successful without order param" do
      response = action.call(params.except(:order))
      expect(response.status).to eq 201
      expect(response.headers["Content-Type"]).to eq "application/json; charset=utf-8"
      expect(response.headers["Content-Location"]).to eq "/api/attrs/#{attr_with_mappings.name}"
      json = JSON.parse(response.body.first, symbolize_names: true)
      expect(json).to eq({
        **attr_attributes.except(:id),
        mappings: mappings_attributes,
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

    it "is failure with name over" do
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

    it "is failure with bad mapping params" do
      response = action.call({
        **params,
        mappings: [
          {provider: "", name: "attr1_1", conversion: nil},
          {name: "attr1_2", conversion: "e2j"},
        ],
      })
      expect(response.status).to eq 400
      expect(response.headers["Content-Type"]).to eq "application/json; charset=utf-8"
      json = JSON.parse(response.body.first, symbolize_names: true)
      expect(json).to eq({
        code: 400,
        message: "Bad Request",
        errors: [{
          mappings: {
            "0": {provider: ["入力が必須です。"], key: ["存在しません。"]},
            "1": {provider: ["存在しません。"], key: ["存在しません。"]},
          },
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
        errors: [{name: ["存在しません。"], type: ["存在しません。"]}],
      })
    end

    describe "existed name" do
      let(:attr_repository) { instance_double(AttrRepository, **attr_repository_stubs, exist_by_name?: true) }

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

    describe "not found provider" do
      # provider1のみない
      let(:providers) {
        providers_attributes
          .reject { |attributes| attributes[:name] == "provider1" }
          .map { |attributes| Provider.new(attributes) }
      }

      it "is failure" do
        response = action.call(params)
        expect(response.status).to eq 422
        expect(response.headers["Content-Type"]).to eq "application/json; charset=utf-8"
        json = JSON.parse(response.body.first, symbolize_names: true)
        expect(json).to eq({
          code: 422,
          message: "Unprocessable Entity",
          errors: [{mappings: {"1": {provider: ["見つかりません。"]}}}],
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
