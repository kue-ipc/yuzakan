# frozen_string_literal: true

RSpec.describe API::Actions::Adapters::Show do
  init_action_spec

  let(:action_opts) {
    # FIXME: アクションのDepsでは自動的に取得できないため、明示的に取得する。
    {adapter_repo: Hanami.app["adapter_repo"]}
  }

  let(:action_params) { {id: "dummy"} }

  shared_context "with hoge id" do
    let(:action_params) { {id: "hoge"} }
  end

  shared_examples "ok restricted" do
    it "is ok" do
      response = action.call(params)
      # expect(response).to be_successful
      expect(response.status).to eq 200
      expect(response.headers["Content-Type"]).to eq "application/json; charset=utf-8"
      json = JSON.parse(response.body.first, symbolize_names: true)
      expect(json).to eq({name: "dummy", label: "ダミー"})
    end

    describe "with test id" do
      it "is ok" do
        response = action.call(**params, id: "test")
        # expect(response).to be_successful
        expect(response.status).to eq 200
        expect(response.headers["Content-Type"]).to eq "application/json; charset=utf-8"
        json = JSON.parse(response.body.first, symbolize_names: true)
        expect(json).to eq({name: "test", label: "テスト"})
      end
    end
  end

  shared_examples "ok" do
    it "is ok" do
      response = action.call(params)
      # expect(response).to be_successful
      expect(response.status).to eq 200
      expect(response.headers["Content-Type"]).to eq "application/json; charset=utf-8"
      json = JSON.parse(response.body.first, symbolize_names: true)
      expect(json).to eq({
        name: "dummy",
        label: "ダミー",
        group: false,
        primary: false,
        params: {schema: {type: "object", properties: {}, required: []}},
      })
    end

    describe "with test id" do
      it "is ok" do
        response = action.call(**params, id: "test")
        # expect(response).to be_successful
        expect(response.status).to eq 200
        expect(response.headers["Content-Type"]).to eq "application/json; charset=utf-8"
        json = JSON.parse(response.body.first, symbolize_names: true)
        expect(json).to eq({
          name: "test",
          label: "テスト",
          group: true,
          primary: true,
          params: {schema: {
            properties: {
              str: {description: "詳細", maxLength: 255, title: "文字列", type: "string"},
              text: {type: "string"},
              int: {type: "integer"},
              float: {type: "number"},
              bool: {type: "boolean"},
              date: {type: "date"},
              time: {type: "time"},
              datetime: {type: "datetime"},
              requiredStr: {maxLength: 255, type: "string"},
              filledStr: {maxLength: 255, minLength: 1, type: "string"},
              patternStr: {maxLength: 255, pattern: "^[a-z]*$", type: "string"},
              fixedStr: {const: "abc", type: "string"},
              defaultStr: {default: "xyz", maxLength: 255, type: "string"},
              encryptedStr: {maxLength: 255, type: "string"},
              list: {enum: ["one", "two", "three"], type: "string"},
            },
            required: ["requiredStr"],
            type: "object",
          }},
        })
      end
    end
  end

  shared_examples "failure" do
    context "with hoge id" do
      include_context "with hoge id"
      it_behaves_like "non-existent"
    end
  end

  shared_examples "show" do
    it_behaves_like "ok"
    it_behaves_like "failure"
  end

  shared_examples "show restricted" do
    it_behaves_like "ok restricted"
    it_behaves_like "failure"
  end

  # test cases

  it_behaves_like "show restricted"

  context "when guest" do
    include_context "when guest"
    it_behaves_like "unauthorized"
  end

  context "when observer" do
    include_context "when observer"
    it_behaves_like "show restricted"
  end

  context "when operator" do
    include_context "when operator"
    it_behaves_like "show restricted"
  end

  context "when administrator" do
    include_context "when administrator"
    it_behaves_like "show"
  end

  context "when superuser" do
    include_context "when superuser"
    it_behaves_like "show"
  end

  context "when logout" do
    include_context "when logout"
    it_behaves_like "unauthenticated"
  end

  context "when first" do
    include_context "when first"
    it_behaves_like "unauthenticated"
  end

  context "when timeover" do
    include_context "when timeover"
    it_behaves_like "session timeout"
  end
end
