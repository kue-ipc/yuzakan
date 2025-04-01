# frozen_string_literal: true

RSpec.describe "POST /api/session", :db, type: :request do
  init_request_spec

  let(:request_headers) {
    {
      "HTTP_ACCEPT" => "application/json",
      "CONTENT_TYPE" => "application/json",
    }
  }
  let(:params) { {username: user.name, password: password} }

  it "is redirect (303 see other)" do
    post "/api/session", params.to_json, request_headers
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

  it "is created on first" do
    with_session(:first) do
      post "/api/session", params.to_json, request_headers
      expect(last_response).to be_created
      expect(last_response.headers["Content-Type"]).to eq "application/json; charset=utf-8"
      json = JSON.parse(last_response.body, symbolize_names: true)
      expect(json[:user]).to eq user.name
    end
  end

  it "is created on logout" do
    with_session(:logout) do
      post "/api/session", params.to_json, request_headers
      expect(last_response).to be_created
      expect(last_response.headers["Content-Type"]).to eq "application/json; charset=utf-8"
      json = JSON.parse(last_response.body, symbolize_names: true)
      expect(json[:user]).to eq user.name
    end
  end

  it "is unprocessable on logout with wrong username params" do
    with_session(:logout) do
      post "/api/session", {**params, username: "a"}.to_json, request_headers
      expect(last_response).to be_unprocessable
      expect(last_response.headers["Content-Type"]).to eq "application/json; charset=utf-8"
      json = JSON.parse(last_response.body, symbolize_names: true)
      expect(json).to eq({
        status: 422,
        message: "Unprocessable Entity",
        errors: ["ユーザー名またはパスワードが違います。"],
      })
    end
  end

  it "is unprocessable on logout with wrong password" do
    with_session(:logout) do
      post "/api/session", {**params, password: "a"}.to_json, request_headers
      expect(last_response).to be_unprocessable
      expect(last_response.headers["Content-Type"]).to eq "application/json; charset=utf-8"
      json = JSON.parse(last_response.body, symbolize_names: true)
      expect(json).to eq({
        status: 422,
        message: "Unprocessable Entity",
        errors: ["ユーザー名またはパスワードが違います。"],
      })
    end
  end

  it "is unprocessable on logout with wrong username and password" do
    with_session(:logout) do
      post "/api/session", {**params, username: "a", password: "a"}.to_json, request_headers
      expect(last_response).to be_unprocessable
      expect(last_response.headers["Content-Type"]).to eq "application/json; charset=utf-8"
      json = JSON.parse(last_response.body, symbolize_names: true)
      expect(json).to eq({
        status: 422,
        message: "Unprocessable Entity",
        errors: ["ユーザー名またはパスワードが違います。"],
      })
    end
  end

  it "is redircet (302 found) on time over" do
    with_session(:timeover) do
      post "/api/session", params.to_json, request_headers
      expect(last_response).to be_redirect
      expect(last_response.status).to be 302
      expect(last_response.headers["Content-Type"]).to eq "application/json; charset=utf-8"
      json = JSON.parse(last_response.body, symbolize_names: true)
      expect(json).to eq({
        status: 302,
        message: "Found",
        location: "/api/session",
        errors: ["セッションがタイムアウトしました。"],
      })
    end
  end
end
