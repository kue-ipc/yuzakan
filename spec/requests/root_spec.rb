# frozen_string_literal: true

RSpec.describe "Root", :db, type: :request do
  init_request_spec

  it "is successful" do
    get "/"

    expect(last_response).to be_successful
  end

  it "is unauthorized on first" do
    with_session(:first) do
      get "/"
      expect(last_response).to be_unauthorized
    end
  end

  it "is unauthorized on logout" do
    with_session(:logout) do
      get "/"
      expect(last_response).to be_unauthorized
    end
  end

  it "is unauthorized on time over" do
    with_session(:timeover) do
      get "/"
      expect(last_response).to be_unauthorized
    end
  end

  context "when level 0 network" do
    let(:network) { Factory[:ipv4_loopback_network, clearance_level: 0] }

    it "is forbidden" do
      get "/"

      expect(last_response).to be_forbidden
    end
  end

  context "when no network" do
    let(:network) { nil }

    it "is forbidden" do
      get "/"

      expect(last_response).to be_forbidden
    end
  end

  context "when no config" do
    let(:config) { nil }

    it "is server error (503 service unavalable)" do
      get "/"

      expect(last_response).to be_server_error
      expect(last_response.status).to be 503
    end
  end
end
