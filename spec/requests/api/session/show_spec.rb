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
    expect({**json, data: {**json[:data], created_at: nil, updated_at: nil}}).to eq({
      status: {code: 200, message: "OK"},
      location: "/api/session",
      data: {
        uuid: uuid,
        user: user.name,
        created_at: nil,
        updated_at: nil,
      },
    })
    expect(Time.parse(json.dig(:data, :created_at))).to be_within(1).of(session[:created_at])
    expect(Time.parse(json.dig(:data, :updated_at))).to be_between(begin_time.floor, end_time)
  end

  it "is ok on first" do
    with_session(:first) do
      begin_time = Time.now
      get "/api/session", request_headers
      end_time = Time.now
      expect(last_response).to be_ok
      expect(last_response.headers["Content-Type"]).to eq "application/json; charset=utf-8"
      json = JSON.parse(last_response.body, symbolize_names: true)
      expect({**json, data: {**json[:data], uuid: nil, created_at: nil, updated_at: nil}}).to eq({
        status: {code: 200, message: "OK"},
        location: "/api/session",
        data: {
          uuid: nil,
          user: nil,
          created_at: nil,
          updated_at: nil,
        },
      })
      expect(json.dig(:data, :uuid)).not_to eq uuid
      expect(Time.parse(json.dig(:data, :created_at))).to be_between(begin_time.floor, end_time)
      expect(Time.parse(json.dig(:data, :updated_at))).to be_between(begin_time.floor, end_time)
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
      expect({**json, data: {**json[:data], created_at: nil, updated_at: nil}}).to eq({
        status: {code: 200, message: "OK"},
        location: "/api/session",
        data: {
          uuid: uuid,
          user: nil,
          created_at: nil,
          updated_at: nil,
        },
      })
      expect(Time.parse(json.dig(:data, :created_at))).to be_within(1).of(logout_session[:created_at])
      expect(Time.parse(json.dig(:data, :updated_at))).to be_between(begin_time.floor, end_time)
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
      expect({**json, data: {**json[:data], created_at: nil, updated_at: nil}}).to eq({
        status: {code: 200, message: "OK"},
        location: "/api/session",
        flash: {warn: "セッションがタイムアウトしました。"},
        data: {
          uuid: uuid,
          user: nil,
          created_at: nil,
          updated_at: nil,
        },
      })
      expect(Time.parse(json.dig(:data, :created_at))).to be_within(1).of(timeover_session[:created_at])
      expect(Time.parse(json.dig(:data, :updated_at))).to be_between(begin_time.floor, end_time)
    end
  end
end
