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
    expect(json[:data].except(:createdAt, :updatedAt)).to eq({
      uuid: uuid,
      user: user.name,
    })
    expect(Time.parse(json[:data][:createdAt])).to be_within(1).of(session[:created_at])
    expect(Time.parse(json[:data][:updatedAt])).to be_between(begin_time.floor, end_time)
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
      expect(json[:data].except(:uuid, :createdAt, :updatedAt)).to eq({
        user: nil,
      })
      expect(json[:data][:uuid]).to match(/\A[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}\z/)
      expect(json[:data][:uuid]).not_to eq uuid
      expect(Time.parse(json[:data][:updatedAt])).to be_between(begin_time.floor, end_time)
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
      expect(json[:data].except(:createdAt, :updatedAt)).to eq({
        uuid: uuid,
        user: nil,
      })
      expect(Time.parse(json[:data][:createdAt])).to be_within(1).of(logout_session[:created_at])
      expect(Time.parse(json[:data][:updatedAt])).to be_between(begin_time.floor, end_time)
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
      expect(json[:data].except(:createdAt, :updatedAt)).to eq({
        uuid: uuid,
        user: nil,
      })
      expect(Time.parse(json[:data][:createdAt])).to be_within(1).of(timeover_session[:created_at])
      expect(Time.parse(json[:data][:updatedAt])).to be_between(begin_time.floor, end_time)
    end
  end
end
