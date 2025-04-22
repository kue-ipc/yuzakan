# frozen_string_literal: true

RSpec.describe "GET /api/auth", :db, type: :request do
  init_request_spec

  let(:request_headers) {
    {
      "HTTP_ACCEPT" => "application/json",
    }
  }

  it "is ok" do
    get "/api/auth", request_headers
    expect(last_response).to be_ok
    expect(last_response.status).to eq 200
    expect(last_response.headers["Content-Type"]).to eq "application/json; charset=utf-8"
    json = JSON.parse(last_response.body, symbolize_names: true)
    expect(json).to eq({
      status: {code: 200, message: "OK"},
      location: "/api/auth",
      data: {username: user.name},
    })
  end

  it "is not found on first" do
    with_session(:first) do
      get "/api/auth", request_headers
      expect(last_response).to be_not_found
      expect(last_response.headers["Content-Type"]).to eq "application/json; charset=utf-8"
      json = JSON.parse(last_response.body, symbolize_names: true)
      expect(json).to eq({
        status: {code: 404, message: "Not Found"},
        location: "/api/auth",
        flash: {error: "ログインしていません。"},
      })
    end
  end

  it "is not found on logout" do
    with_session(:logout) do
      get "/api/auth", request_headers
      expect(last_response).to be_not_found
      expect(last_response.headers["Content-Type"]).to eq "application/json; charset=utf-8"
      json = JSON.parse(last_response.body, symbolize_names: true)
      expect(json).to eq({
        status: {code: 404, message: "Not Found"},
        location: "/api/auth",
        flash: {error: "ログインしていません。"},
      })
    end
  end

  it "is not found on time over" do
    with_session(:timeover) do
      get "/api/auth", request_headers
      expect(last_response).to be_not_found
      expect(last_response.headers["Content-Type"]).to eq "application/json; charset=utf-8"
      json = JSON.parse(last_response.body, symbolize_names: true)
      expect(json).to eq({
        status: {code: 404, message: "Not Found"},
        location: "/api/auth",
        flash: {error: "ログインしていません。", warn: "セッションがタイムアウトしました。"},
      })
    end
  end
end
