# frozen_string_literal: true

RSpec.describe API::Actions::Adapters::Index do
  init_action_spec

  let(:action_opts) {
    #     dummy_adapter = Yuzakan::AdapterRepo::AdapterStruct.new(name: "dummy", class: Yuzakan::Adapters::Dummy)
    #     mock_adapter = Yuzakan::AdapterRepo::AdapterStruct.new(name: "mock", class: Yuzakan::Adapters::Mock)
    #     test_adapter = Yuzakan::AdapterRepo::AdapterStruct.new(name: "test", class: Yuzakan::Adapters::Test)
    #     vendor_dummy_adapter = Yuzakan::AdapterRepo::AdapterStruct.new(name: "vendor.dummy", class: Yuzakan::Adapters::Dummy)

    #     allow(adapetr_repo).to receive(:all).and_return([
    #       dummy_adapter,
    #       mock_adapter,
    #       test_adapter,
    #       vendor_dummy_adapter,
    #     ])
    #     allow(adapetr_repo).to receive(:exist?).with("dummy").and_return(true)
    #     allow(adapetr_repo).to receive(:get).with("dummy").and_return(dummy_adapter)
    #     allow(adapetr_repo).to receive(:exist?).with("test").and_return(true)
    #     allow(adapetr_repo).to receive(:get).with("test").and_return(test_adapter)
    #     allow(adapetr_repo).to receive(:exist?).with("hoge").and_return(false)

    # {adapter_repo: adapter_repo}
    {}
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
        {name: "mock",        label: "モック"},
        {name: "test",        label: "テスト"},
        {name: "vendor.dummy", label: "vendor.dummy"},
      ])
    end
  end

  shared_examples "index" do
    it_behaves_like "ok"
  end

  # test cases

  it_behaves_like "ok"

  context "when guest" do
    include_context "when guest"
    it_behaves_like "unauthorized"
  end

  context "when observer" do
    include_context "when observer"
    it_behaves_like "index"
  end

  context "when operator" do
    include_context "when operator"
    it_behaves_like "index"
  end

  context "when administrator" do
    include_context "when administrator"
    it_behaves_like "index"
  end

  context "when superuser" do
    include_context "when superuser"
    it_behaves_like "index"
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
    it_behaves_like "session timeout"
  end
end
