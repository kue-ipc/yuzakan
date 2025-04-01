# frozen_string_literal: true

RSpec.describe "POST /api/session", :db, type: :request do
  let(:user) { Factory[:user] }
  let(:config) { Factory[:config] }
  # trusted level 5 network 127.0.0.0/8
  let(:network) { Factory[:network_ipv4_loopback] }
  let(:session) {
    {user: user.name, created_at: Time.now, updated_at: Time.now}
  }
  # default REMOTE_ADDR: 127.0.0.1
  let(:env) { {**request_headers, "rack.session" => session} }
  let(:request_headers) {
    {
      "HTTP_ACCEPT" => "application/json",
      "CONTENT_TYPE" => "application/json",
    }
  }
  let(:params) { {username: user.name, password: password} }
  let(:password) { Faker::Internet.password }

  before do
    user
    config
    network
  end

  it "is redirection (see other)" do
    post "/api/session", params.to_json, env

    expect(last_response).to be_redirect
    expect(last_response.status).to eq 303
    expect(last_response.headers["Location"]).to eq "/api/session"
    expect(last_response.headers["Content-Type"]).to eq "application/json; charset=utf-8"
    json = JSON.parse(last_response.body, symbolize_names: true)
    expect(json).to eq({
      status: 303,
      message: "See Other",
      location: "/api/session",
    })
  end

  context "when no login" do
    let(:session) { {uuid: uuid, user: nil} }

    it "is successful" do
      post "/api/session", params.to_json, env

      warn last_response.body
      warn last_response.status
      expect(last_response).to be_created
    end
  end
end
