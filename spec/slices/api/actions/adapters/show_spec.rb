# frozen_string_literal: true

RSpec.describe API::Actions::Adapters::Show do
  init_action_spec

  let(:action_params) { {id: id} }

  let(:action_opts) { {adapter_map: adapter_map} }

  let(:adapter_map) {
    [
      {name: "dummy", class: Yuzakan::Adapters::Dummy},
      {name: "local", class: Yuzakan::Adapters::Local},
      {name: "mock", class: Yuzakan::Adapters::Mock},
      {name: "test", class: Yuzakan::Adapters::Test},
      {name: "vendor.dummy", class: Yuzakan::Adapters::Dummy},
    ].to_h { |adapter| [adapter[:name], adapter] }
  }

  let(:id) { "dummy" }

  shared_examples "ok" do
    it "is successful" do
      response = action.call(params)
      expect(response).to be_successful
      expect(response.status).to eq 200
      expect(response.headers["Content-Type"]).to eq "application/json; charset=utf-8"
      json = JSON.parse(response.body.first, symbolize_names: true)
      expect(json[:data]).to eq({name: "dummy", label: "ダミー"})
    end

    it "is successful with test adapter" do
      response = action.call({**params, id: "test"})
      expect(response).to be_successful
      expect(response.status).to eq 200
      expect(response.headers["Content-Type"]).to eq "application/json; charset=utf-8"
      json = JSON.parse(response.body.first, symbolize_names: true)
      expect(json[:data]).to eq({name: "test", label: "テスト"})
    end
  end

  shared_examples "ok with params type" do
    it "is successful" do
      response = action.call(params)
      expect(response).to be_successful
      expect(response.status).to eq 200
      expect(response.headers["Content-Type"]).to eq "application/json; charset=utf-8"
      json = JSON.parse(response.body.first, symbolize_names: true)
      expect(json[:data]).to eq({
        name: "dummy",
        label: "ダミー",
        group: false,
        primary: false,
        params: {schema: {type: "object", properties: {}, required: []}},
      })
    end

    it "is successful with test adapter" do
      response = action.call({**params, id: "test"})
      expect(response).to be_successful
      expect(response.status).to eq 200
      expect(response.headers["Content-Type"]).to eq "application/json; charset=utf-8"
      json = JSON.parse(response.body.first, symbolize_names: true)
      expect(json[:data]).to eq({
        name: "test",
        label: "テスト",
        group: true,
        primary: true,
        params: {schema: {
          type: "object",
          properties: {
            str: {title: "文字列", description: "詳細", type: "string", maxLength: 255},
            text: {type: "string"},
            int: {type: "integer"},
            float: {type: "number"},
            bool: {type: "boolean"},
            date: {type: "date"},
            time: {type: "time"},
            datetime: {type: "datetime"},
            requiredStr: {type: "string", maxLength: 255},
            filledStr: {type: "string", minLength: 1, maxLength: 255},
            patternStr: {type: "string", maxLength: 255, pattern: "^[a-z]*$"},
            fixedStr: {type: "string", const: "abc"},
            defaultStr: {type: "string", maxLength: 255, default: "xyz"},
            encryptedStr: {type: "string", maxLength: 255},
            list: {type: "string", enum: ["one", "two", "three"]},
          },
          required: ["requiredStr"],
        }},
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

  # TODO: 本当にparamsが必要か？
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
