# frozen_string_literal: true

RSpec.describe "GET /api/session", :db, type: :request do
  init_request_spec

  let(:request_headers) {
    {
      "HTTP_ACCEPT" => "application/json",
    }
  }

  it "is ok" do
    begin_time = Time.now
    get "/api/session", request_headers
    end_time = Time.now
    expect(last_response).to be_ok
    expect(last_response.headers["Content-Type"]).to eq "application/json; charset=utf-8"
    json = JSON.parse(last_response.body, symbolize_names: true)
    expect(json.except(:data)).to eq({
      status: {code: 200, message: "OK"},
      location: "/api/session",
    })
    expect(json[:data].except(:expiresAt)).to eq({
      uuid: uuid,
      user: user.name,
      trusted: true,
    })
    expect(Time.parse(json[:data][:expiresAt])).to be_between(begin_time.floor + 3600, end_time + 3600)
  end

  it "is ok on first" do
    with_session(:first) do
      begin_time = Time.now
      get "/api/session", request_headers
      end_time = Time.now
      expect(last_response).to be_ok
      expect(last_response.headers["Content-Type"]).to eq "application/json; charset=utf-8"
      json = JSON.parse(last_response.body, symbolize_names: true)
      expect(json.except(:data)).to eq({
        status: {code: 200, message: "OK"},
        location: "/api/session",
      })
      expect(json[:data].except(:uuid, :expiresAt)).to eq({
        user: nil,
        trusted: false,
      })
      expect(json[:data][:uuid]).to be_a_uuid(version: 4)
      expect(json[:data][:uuid]).not_to eq uuid
      expect(Time.parse(json[:data][:expiresAt])).to be_between(begin_time.floor + 3600, end_time + 3600)
    end
  end

  it "is ok on logout" do
    with_session(:logout) do
      begin_time = Time.now
      get "/api/session", request_headers
      end_time = Time.now
      expect(last_response).to be_ok
      expect(last_response.headers["Content-Type"]).to eq "application/json; charset=utf-8"
      json = JSON.parse(last_response.body, symbolize_names: true)
      expect(json.except(:data)).to eq({
        status: {code: 200, message: "OK"},
        location: "/api/session",
      })
      expect(json[:data].except(:expiresAt)).to eq({
        uuid: uuid,
        user: nil,
        trusted: false,
      })
      expect(Time.parse(json[:data][:expiresAt])).to be_between(begin_time.floor + 3600, end_time + 3600)
    end
  end

  it "is ok on time over" do
    with_session(:timeover) do
      begin_time = Time.now
      get "/api/session", request_headers
      end_time = Time.now
      expect(last_response).to be_ok
      expect(last_response.headers["Content-Type"]).to eq "application/json; charset=utf-8"
      json = JSON.parse(last_response.body, symbolize_names: true)
      expect(json.except(:data)).to eq({
        status: {code: 200, message: "OK"},
        location: "/api/session",
        flash: {warn: "セッションがタイムアウトしました。"},
      })
      expect(json[:data].except(:expiresAt)).to eq({
        uuid: uuid,
        user: nil,
        trusted: false,
      })
      expect(Time.parse(json[:data][:expiresAt])).to be_between(begin_time.floor + 3600, end_time + 3600)
    end
  end
end
