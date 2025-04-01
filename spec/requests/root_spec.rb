# frozen_string_literal: true

RSpec.describe "Root", :db, type: :request do
  init_request_spec

  it "is successful" do
    get "/"

    expect(last_response).to be_successful
  end

  context "when level 0 network" do
    let(:network) { Factory[:network_ipv4_loopback, clearance_level: 0] }

    it "is 403 forbidden" do
      get "/"

      expect(last_response).to be_forbidden
    end
  end

  context "when no network" do
    let(:network) { nil }

    it "is 403 forbidden" do
      get "/"

      expect(last_response).to be_forbidden
    end
  end

  context "when no login" do
    let(:session) { {} }

    it "is 401 unauthorized" do
      get "/"

      expect(last_response).to be_unauthorized
    end
  end

  context "when no config" do
    let(:config) { nil }

    it "is 503 service unavalable" do
      get "/"

      expect(last_response).to be_server_error
      expect(last_response.status).to be(503)
    end
  end
end
