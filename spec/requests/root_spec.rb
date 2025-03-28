# frozen_string_literal: true

RSpec.describe "Root", :db, type: :request do
  let(:user) { Factory[:user] }
  let(:config) { Factory[:config] }
  # trusted level 5 network 127.0.0.0/8
  let(:network) { Factory[:network_ipv4_loopback] }
  let(:session) {
    {user: user.name, created_at: Time.now, updated_at: Time.now}
  }
  # REMOTE_ADDR: 127.0.0.1
  let(:env) { {"rack.session" => session} }

  before do
    user
    config
    network
  end

  it "is successful" do
    get "/", {}, env

    expect(last_response).to be_successful
  end

  context "when level 0 network" do
    let(:network) { Factory[:network_ipv4_loopback, clearance_level: 0] }

    it "is 403 forbidden" do
      get "/", {}, env

      expect(last_response.status).to be(403)
    end
  end

  context "when no network" do
    let(:network) { nil }

    it "is 403 forbidden" do
      get "/", {}, env

      expect(last_response.status).to be(403)
    end
  end

  context "when no login" do
    let(:session) { {} }

    it "is 401 unauthorized" do
      get "/", {}, env

      expect(last_response.status).to be(401)
    end
  end

  context "when no config" do
    let(:config) { nil }

    it "is 503 service unavalable" do
      get "/"

      expect(last_response.status).to be(503)
    end
  end
end
