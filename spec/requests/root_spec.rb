# frozen_string_literal: true

RSpec.describe "Root", :db, type: :request do
  let(:user) { Factory[:user] }
  let(:config) { Factory[:config] }
  let(:network) { Factory[:network] }
  let(:session) do
    {user: user.name, created_at: Time.now, updated_at: Time.now}
  end
  # REMOTE_ADDR: 127.0.0.1
  let(:env) { {"rack.session" => session} }

  before do
    user
    config
    network
  end

  context "when authenticated and authorized" do
    it "is successful" do
      get "/", {}, env

      expect(last_response).to be_successful
    end
  end

  context "when unauthorized" do
    let(:network) { Factory[:network_level0] }

    it "is 403 forbidden" do
      get "/", {}, env

      expect(last_response.status).to be(403)
    end
  end

  context "when unauthorized without network" do
    let(:network) { nil }

    it "is 403 forbidden" do
      get "/", {}, env

      expect(last_response.status).to be(403)
    end
  end

  context "when unauthenticated" do
    let(:session) { {} }

    it "is 401 unauthorized" do
      get "/", {}, env

      expect(last_response.status).to be(401)
    end
  end

  context "when unintialized" do
    let(:config) { nil }

    it "is 503 service unavalable" do
      get "/"

      expect(last_response.status).to be(503)
    end
  end
end
