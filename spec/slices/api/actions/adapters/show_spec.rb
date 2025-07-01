# frozen_string_literal: true

RSpec.describe API::Actions::Adapters::Show do
  init_action_spec

  let(:action_params) { {id: id} }
  let(:id) { "dummy" }

  shared_examples "ok" do
    it "is successful" do
      response = action.call(params)
      expect(response).to be_successful
      expect(response.status).to eq 200
      expect(response.headers["Content-Type"]).to eq "application/json; charset=utf-8"
      json = JSON.parse(response.body.first, symbolize_names: true)
      expect(json[:data]).to eq({name: "dummy", displayName: "ダミー", group: false})
    end

    it "is successful with test adapter" do
      response = action.call({**params, id: "test"})
      expect(response).to be_successful
      expect(response.status).to eq 200
      expect(response.headers["Content-Type"]).to eq "application/json; charset=utf-8"
      json = JSON.parse(response.body.first, symbolize_names: true)
      expect(json[:data]).to eq({name: "test", displayName: "テスト", group: true})
    end
  end

  shared_examples "ok with params type" do
    it "is successful" do
      response = action.call(params)
      expect(response).to be_successful
      expect(response.status).to eq 200
      expect(response.headers["Content-Type"]).to eq "application/json; charset=utf-8"
      json = JSON.parse(response.body.first, symbolize_names: true)
      expect(json[:data]).to eq({name: "dummy", displayName: "ダミー", group: false, paramTypes: []})
    end

    it "is successful with test adapter" do
      response = action.call({**params, id: "test"})
      expect(response).to be_successful
      expect(response.status).to eq 200
      expect(response.headers["Content-Type"]).to eq "application/json; charset=utf-8"
      json = JSON.parse(response.body.first, symbolize_names: true)
      expect(json[:data]).to eq({
        name: "test",
        displayName: "テスト",
        group: true,
        paramTypes: [
          {name: "default", displayName: "default", description: nil, type: "string", default: nil, fixed: false,
           encrypted: false, input: "text", list: nil, required: true, placeholder: nil,},
          {name: "str", displayName: "文字列", description: "詳細", type: "string", default: nil, fixed: false,
           encrypted: false, input: "text", list: nil, required: true, placeholder: "プレースホルダー",},
          {name: "str_default", displayName: "デフォルト値", description: nil, type: "string", default: "デフォルト", fixed: false, encrypted: false, input: "text", list: nil, required: false, placeholder: "デフォルト"},
          {name: "str_fixed", displayName: "固定値", description: nil, type: "string", default: "固定", fixed: true,
           encrypted: false, input: "text", list: nil, required: false, placeholder: "固定",},
          {name: "str_required", displayName: "必須文字列", description: nil, type: "string", default: nil, fixed: false,
           encrypted: false, input: "text", list: nil, required: true, placeholder: nil,},
          {name: "str_enc", displayName: "暗号文字列", description: nil, type: "string", default: nil, fixed: false,
           encrypted: true, input: "text", list: nil, required: true, placeholder: nil,},
          {name: "text", displayName: "テキスト", description: nil, type: "text", default: nil, fixed: false,
           encrypted: false, input: "textarea", list: nil, required: true, placeholder: nil,},
          {name: "int", displayName: "整数", description: nil, type: "integer", default: nil, fixed: false,
           encrypted: false, input: "number", list: nil, required: true, placeholder: nil,},
          {name: "list", displayName: "リスト", description: nil, type: "string", default: "default", fixed: false,
           encrypted: false, input: "text", list: [
             {name: "default", displayName: "デフォルト", value: "default", deprecated: false},
             {name: "other", displayName: "その他", value: "other", deprecated: false},
             {name: "deprecated", displayName: "非推奨", value: "deprecated", deprecated: true},
           ], required: false, placeholder: "default",},
        ],
      })
    end
  end

  it_behaves_like "ok"

  context "with nonexstent id" do
    let(:id) { "hoge" }

    it_behaves_like "not found"
  end

  context "when guest" do
    include_context "when guest"
    it_behaves_like "forbidden"
  end

  context "when observer" do
    include_context "when observer"
    it_behaves_like "ok"

    context "with nonexstent id" do
      let(:id) { "hoge" }

      it_behaves_like "not found"
    end
  end

  context "when operator" do
    include_context "when operator"
    it_behaves_like "ok"

    context "with nonexstent id" do
      let(:id) { "hoge" }

      it_behaves_like "not found"
    end
  end

  # TODO: 本当にparamsTypesが必要か？
  context "when administrator" do
    include_context "when administrator"
    it_behaves_like "ok with params type"
    context "with nonexstent id" do
      let(:id) { "hoge" }

      it_behaves_like "not found"
    end
  end

  context "when superuser" do
    include_context "when superuser"
    it_behaves_like "ok with params type"
    context "with nonexstent id" do
      let(:id) { "hoge" }

      it_behaves_like "not found"
    end
  end
end
