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
      expect(response).to be_successful
      expect(response.status).to eq 200
      expect(response.headers["Content-Type"]).to eq "application/json; charset=utf-8"
      json = JSON.parse(response.body.first)
      expect(json).to eq({"name" => "dummy", "label" => "ダミー"})
    end

    describe "with test id" do
      it "is ok" do
        response = action.call(**params, id: "test")
        expect(response).to be_successful
        expect(response.status).to eq 200
        expect(response.headers["Content-Type"]).to eq "application/json; charset=utf-8"
        json = JSON.parse(response.body.first)
        expect(json).to eq({"name" => "test", "label" => "テスト"})
      end
    end
  end

  shared_examples "ok" do
    it "is ok" do
      response = action.call(params)
      expect(response).to be_successful
      expect(response.status).to eq 200
      expect(response.headers["Content-Type"]).to eq "application/json; charset=utf-8"
      json = JSON.parse(response.body.first)
      expect(json).to eq({
        "name" => "dummy",
        "label" => "ダミー",
        "group" => false,
        "primary" => false,
        "params" => {"schema" => {"type" => "object", "properties" => {}, "required" => []}},
      })
    end

    describe "with test id" do
      it "is ok" do
        response = action.call(**params, id: "test")
        expect(response).to be_successful
        expect(response.status).to eq 200
        expect(response.headers["Content-Type"]).to eq "application/json; charset=utf-8"
        json = JSON.parse(response.body.first)
        expect(json).to eq({
          "name" => "test",
          "label" => "テスト",
          "group" => true,
          "primary" => true,
          "params" => {"schema" => {
            "type" => "object",
            "properties" => {
              str: {title: "文字列", description: "詳細", "type" => "string", maxLength: 255},
              text: {"type" => "string"},
              int: {"type" => "integer"},
              float: {"type" => "number"},
              bool: {"type" => "boolean"},
              date: {"type" => "date"},
              time: {"type" => "time"},
              datetime: {"type" => "datetime"},
              requiredStr: {"type" => "string", maxLength: 255},
              filledStr: {"type" => "string", minLength: 1, maxLength: 255},
              patternStr: {"type" => "string", maxLength: 255, pattern: "^[a-z]*$"},
              fixedStr: {"type" => "string", const: "abc"},
              defaultStr: {"type" => "string", maxLength: 255, default: "xyz"},
              encryptedStr: {"type" => "string", maxLength: 255},
              list: {"type" => "string", enum: ["one", "two", "three"]},
            },
            "required" => ["requiredStr"],
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
    it_behaves_like "ok"
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
