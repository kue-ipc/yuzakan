# frozen_string_literal: true

RSpec.describe API::Actions::System::Show do
  init_action_spec

  shared_examples "ok" do
    it "is ok" do
      response = action.call(params)
      expect(response).to be_successful
      expect(response.status).to eq 200
      expect(response.headers["Content-Type"]).to eq "application/json; charset=utf-8"
      json = JSON.parse(response.body.first, symbolize_names: true)
      expect(json[:data]).to eq({
        url: "http://0.0.0.0:2300/",
        title: config.title,
        domain: config.domain,
        contact: {name: config.contact_name, email: config.contact_email, phone: config.contact_phone},
        app: {name: "Yuzakan", version: Yuzakan::Version::VERSION,
              license: File.read(File.join(__dir__, "../../../../../LICENSE")),},
      })
    end
  end

  it_behaves_like "ok"

  context "when logout" do
    include_context "when logout"
    it_behaves_like "ok"
  end

  context "when first" do
    include_context "when first"
    it_behaves_like "ok"
  end

  context "when timeover" do
    include_context "when timeover"
    it_behaves_like "ok"
  end

  describe "config without domain" do
    let(:config) { Factory.structs[:config_without_domain] }

    it "is ok" do
      response = action.call(params)
      expect(response.status).to eq 200
      expect(response.headers["Content-Type"]).to eq "application/json; charset=utf-8"
      json = JSON.parse(response.body.first, symbolize_names: true)
      expect(json[:data]).to eq({
        url: "http://0.0.0.0:2300/",
        title: config.title,
        domain: "",
        contact: {name: config.contact_name, email: config.contact_email, phone: config.contact_phone},
        app: {name: "Yuzakan", version: Yuzakan::Version::VERSION,
              license: File.read(File.join(__dir__, "../../../../../LICENSE")),},
      })
    end
  end

  describe "config without contact" do
    let(:config) { Factory.structs[:config_without_contact] }

    it "is ok" do
      response = action.call(params)
      expect(response.status).to eq 200
      expect(response.headers["Content-Type"]).to eq "application/json; charset=utf-8"
      json = JSON.parse(response.body.first, symbolize_names: true)
      expect(json[:data]).to eq({
        url: "http://0.0.0.0:2300/",
        title: config.title,
        domain: config.domain,
        contact: {name: "", email: "", phone: ""},
        app: {name: "Yuzakan", version: Yuzakan::Version::VERSION,
              license: File.read(File.join(__dir__, "../../../../../LICENSE")),},
      })
    end
  end

  describe "no config" do
    let(:config) { nil }

    it "is ok" do
      response = action.call(params)
      expect(response.status).to eq 200
      expect(response.headers["Content-Type"]).to eq "application/json; charset=utf-8"
      json = JSON.parse(response.body.first, symbolize_names: true)
      expect(json[:data]).to eq({
        url: "http://0.0.0.0:2300/",
        title: nil,
        domain: nil,
        contact: {name: nil, email: nil, phone: nil},
        app: {name: "Yuzakan", version: Yuzakan::Version::VERSION,
              license: File.read(File.join(__dir__, "../../../../../LICENSE")),},
      })
    end
  end
end
