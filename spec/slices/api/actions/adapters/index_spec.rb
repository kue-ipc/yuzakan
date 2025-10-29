# frozen_string_literal: true

RSpec.describe API::Actions::Adapters::Index do
  init_action_spec

  let(:action_opts) { {adapter_map: adapter_map} }

  let(:adapter_map) {
    {
      "dummy" => Yuzakan::Adapters::Dummy,
      "local" => Yuzakan::Adapters::Local,
      "mock" => Yuzakan::Adapters::Mock,
      "test" => Yuzakan::Adapters::Test,
      "vendor.dummy" => Yuzakan::Adapters::Dummy,
    }
  }

  shared_examples "ok" do
    it "is ok" do
      response = action.call(params)
      expect(response).to be_successful
      expect(response.status).to eq 200
      expect(response.headers["Content-Type"]).to eq "application/json; charset=utf-8"
      json = JSON.parse(response.body.first, symbolize_names: true)
      expect(json[:data]).to eq([
        {name: "dummy",       label: "ダミー"},
        {name: "local",       label: "ローカル"},
        {name: "mock",        label: "モック"},
        {name: "test",        label: "テスト"},
        {name: "vendor.dummy", label: "ダミー"},
      ])
    end
  end

  it_behaves_like "ok"

  context "when guest" do
    include_context "when guest"
    it_behaves_like "forbidden"
  end

  context "when observer" do
    include_context "when observer"
    it_behaves_like "ok"
  end

  context "when operator" do
    include_context "when operator"
    it_behaves_like "ok"
  end

  context "when administrator" do
    include_context "when administrator"
    it_behaves_like "ok"
  end

  context "when superuser" do
    include_context "when superuser"
    it_behaves_like "ok"
  end

  context "when logout" do
    include_context "when logout"
    it_behaves_like "unauthorized"
  end

  context "when first" do
    include_context "when first"
    it_behaves_like "unauthorized"
  end

  context "when timeover" do
    include_context "when timeover"
    it_behaves_like "unauthorized session timeout"
  end
end
