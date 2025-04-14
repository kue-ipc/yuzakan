# frozen_string_literal: true

RSpec.describe API::Actions::Session::Show do
  init_action_spec

  it "is successful" do
    begin_time = Time.now
    response = action.call(params)
    end_time = Time.now
    expect(response).to be_successful
    expect(response.status).to eq 200
    expect(response.headers["Content-Type"]).to eq "application/json; charset=utf-8"
    json = JSON.parse(response.body.first, symbolize_names: true)
    expect(json.keys).to contain_exactly(:uuid, :user, :created_at, :updated_at)
    expect(json[:uuid]).to eq uuid
    expect(json[:user]).to eq user.name
    expect(Time.iso8601(json[:created_at])).to be_between(begin_time.floor, end_time)
    expect(Time.iso8601(json[:updated_at])).to eq Time.iso8601(json[:created_at])
  end

  context "when no login" do
    let(:session) { {uuid: uuid, user: nil} }

    it "is successful" do
      begin_time = Time.now
      response = action.call(params)
      end_time = Time.now
      expect(response).to be_successful
      expect(response.status).to eq 200
      expect(response.headers["Content-Type"]).to eq "application/json; charset=utf-8"
      json = JSON.parse(response.body.first, symbolize_names: true)
      expect(json.keys).to contain_exactly(:uuid, :user, :created_at, :updated_at)
      expect(json[:uuid]).to eq uuid
      expect(json[:user]).to eq user.name
      expect(Time.iso8601(json[:created_at])).to be_between(begin_time.floor, end_time)
      expect(Time.iso8601(json[:updated_at])).to eq Time.iso8601(json[:created_at])
    end
  end

  context "when no session" do
    let(:session) { {} }

    it "is successful" do
      begin_time = Time.now
      response = action.call(params)
      end_time = Time.now
      expect(response).to be_successful
      expect(response.status).to eq 200
      expect(response.headers["Content-Type"]).to eq "application/json; charset=utf-8"
      json = JSON.parse(response.body.first, symbolize_names: true)
      expect(json.keys).to contain_exactly(:uuid, :user, :created_at, :updated_at)
      expect(json[:uuid]).to eq uuid
      expect(json[:user]).to eq user.name
      expect(Time.iso8601(json[:created_at])).to be_between(begin_time.floor, end_time)
      expect(Time.iso8601(json[:updated_at])).to eq Time.iso8601(json[:created_at])
    end
  end

  describe "session timeout" do
    let(:session) { {uuid: uuid, user_id: user.id, created_at: Time.now - 7200, updated_at: Time.now - 7200} }

    it "is error" do
      response = action.call(params)
      expect(response.status).to eq 401
      expect(response.headers["Content-Type"]).to eq "#{format}; charset=utf-8"
      json = JSON.parse(response.body.first, symbolize_names: true)
      expect(json).to eq({
        code: 401,
        message: "Unauthorized",
        errors: ["セッションがタイムアウトしました。"],
      })
    end
  end
end
