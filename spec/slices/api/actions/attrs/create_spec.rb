# frozen_string_literal: true

RSpec.describe API::Actions::Attrs::Create do
  init_action_spec

  let(:action_opts) { {
    attr_repo: attr_repo,
    provider_repo: provider_repo,
  } }
  let(:action_params) {
    {
      **attr.to_h.except(:id),
      mappings: mappings.to_h,
    }
  }

  it "is failure" do
    response = action.call(params)
    expect(response).to be_client_error
    expect(response.status).to eq 403
    expect(response.headers["Content-Type"]).to eq "application/json; charset=utf-8"
    json = JSON.parse(response.body.first, symbolize_names: true)
    expect(json).to eq({status: {code: 403, message: "Forbidden"}})
  end

  describe "admin" do
    let(:user) { User.new(**user_attributes, clearance_level: 5) }
    let(:client) { "127.0.0.1" }

    it "is successful" do
      response = action.call(params)
      expect(response.status).to eq 201
      expect(response.headers["Content-Type"]).to eq "#{format}; charset=utf-8"
      expect(response.headers["Content-Location"]).to eq "/api/attrs/#{attr_with_mappings.name}"
      json = JSON.parse(response.body.first, symbolize_names: true)
      expect(json).to eq({
        **attr_attributes.except(:id),
        mappings: mappings_attributes,
      })
    end

    it "is successful without order param" do
      response = action.call(params.except(:order))
      expect(response.status).to eq 201
      expect(response.headers["Content-Type"]).to eq "#{format}; charset=utf-8"
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
      expect(response.headers["Content-Type"]).to eq "#{format}; charset=utf-8"
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
      expect(response.headers["Content-Type"]).to eq "#{format}; charset=utf-8"
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
      expect(response.headers["Content-Type"]).to eq "#{format}; charset=utf-8"
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
      expect(response.headers["Content-Type"]).to eq "#{format}; charset=utf-8"
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
      expect(response.headers["Content-Type"]).to eq "#{format}; charset=utf-8"
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
        expect(response.headers["Content-Type"]).to eq "#{format}; charset=utf-8"
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
        expect(response.headers["Content-Type"]).to eq "#{format}; charset=utf-8"
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
        expect(response.headers["Content-Type"]).to eq "#{format}; charset=utf-8"
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
      expect(response.headers["Content-Type"]).to eq "#{format}; charset=utf-8"
      json = JSON.parse(response.body.first, symbolize_names: true)
      expect(json).to eq({code: 401, message: "Unauthorized"})
    end
  end
end
