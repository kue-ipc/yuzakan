# frozen_string_literal: true

RSpec.describe API::Actions::Adapters::Show do
  init_action_spec

  let(:action_opts) {
    dummy_adapter = Yuzakan::AdapterRepo::AdapterStruct.new(name: "dummy", class: Yuzakan::Adapters::Dummy)
    test_adapter = Yuzakan::AdapterRepo::AdapterStruct.new(name: "test", class: Yuzakan::Adapters::Test)
    allow(adapter_repo).to receive(:exist?).with(id).and_return(true)
    allow(adapter_repo).to receive(:exist?).with("test").and_return(true)
    allow(adapter_repo).to receive(:exist?).with("hoge").and_return(false)
    allow(adapter_repo).to receive(:get).with(id).and_return(dummy_adapter)
    allow(adapter_repo).to receive(:get).with("test").and_return(test_adapter)
    # allow(adapter_repo).to receive(:get).with("hoge").and_return(nil)
    {adapter_repo: adapter_repo}
  }

  let(:action_params) { {id: id} }

  let(:id) { "dummy" }

  shared_examples "ok restrict" do
    it "is ok" do
      response = action.call(params)
      expect(response).to be_successful
      expect(response.status).to eq 200
      expect(response.headers["Content-Type"]).to eq "application/json; charset=utf-8"
      json = JSON.parse(response.body.first, symbolize_names: true)
      expect(json[:data]).to eq({name: "dummy", label: "ダミー"})
    end

    describe "with test id" do
      let(:id) { "test" }

      it "is ok" do
        response = action.call(params)
        expect(response).to be_successful
        expect(response.status).to eq 200
        expect(response.headers["Content-Type"]).to eq "application/json; charset=utf-8"
        json = JSON.parse(response.body.first, symbolize_names: true)
        expect(json[:data]).to eq({name: "test", label: "テスト"})
      end
    end
  end

  shared_examples "ok" do
    it "is ok" do
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

    describe "with test id" do
      let(:id) { "test" }

      it "is ok" do
        response = action.call(params)
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
  end

  shared_examples "failure" do
    describe "with hoge id" do
      let(:id) { "hoge" }
      it_behaves_like "not found"
    end
  end

  it_behaves_like "ok restrict"
  it_behaves_like "failure"

  context "when guest" do
    include_context "when guest"
    it_behaves_like "forbidden"
  end

  context "when observer" do
    include_context "when observer"
    it_behaves_like "ok restrict"
    it_behaves_like "failure"
  end

  context "when operator" do
    include_context "when operator"
    it_behaves_like "ok restrict"
    it_behaves_like "failure"
  end

  # TODO: 本当にparamsが必要か？
  context "when administrator" do
    include_context "when administrator"
    it_behaves_like "ok"
    it_behaves_like "failure"
  end

  context "when superuser" do
    include_context "when superuser"
    it_behaves_like "ok"
    it_behaves_like "failure"
  end
end
