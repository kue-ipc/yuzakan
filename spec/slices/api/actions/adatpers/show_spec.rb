# frozen_string_literal: true

RSpec.describe API::Actions::Adapters::Show do
  init_action_spec

  let(:action_params) { {id: "dummy"} }

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

  it "is failure with unknown id" do
    response = action.call({**params, id: "hoge"})
    expect(response).to be_client_error
    expect(response.status).to eq 404
    expect(response.headers["Content-Type"]).to eq "application/json; charset=utf-8"
    json = JSON.parse(response.body.first, symbolize_names: true)
    expect(json[:flash]).to eq({invalid: {id: ["存在しません。"]}})
  end

  describe "admin" do
    let(:user) { create_struct(:user, :superuser) }

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

    it "is failure with unknown id" do
      response = action.call({**params, id: "hoge"})
      expect(response).to be_client_error
      expect(response.status).to eq 404
      expect(response.headers["Content-Type"]).to eq "application/json; charset=utf-8"
      json = JSON.parse(response.body.first, symbolize_names: true)
      expect(json[:flash]).to eq({invalid: {id: ["存在しません。"]}})
    end
  end
end
