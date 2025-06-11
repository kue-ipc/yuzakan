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
    expect(json[:data].keys).to contain_exactly(:uuid, :user, :createdAt, :updatedAt)
    expect(json[:data][:uuid]).to eq uuid
    expect(json[:data][:user]).to eq user.name
    expect(Time.parse(json[:data][:createdAt])).to be_within(1).of(session[:created_at])
    expect(Time.parse(json[:data][:updatedAt])).to be_between(begin_time.floor, end_time)
  end

  context "when no login" do
    let(:session) { logout_session }

    it "is successful" do
      begin_time = Time.now
      response = action.call(params)
      end_time = Time.now
      expect(response).to be_successful
      expect(response.status).to eq 200
      expect(response.headers["Content-Type"]).to eq "application/json; charset=utf-8"
      json = JSON.parse(response.body.first, symbolize_names: true)
      expect(json[:data].keys).to contain_exactly(:uuid, :user, :createdAt, :updatedAt)
      expect(json[:data][:uuid]).to eq uuid
      expect(json[:data][:user]).to be_nil
      expect(Time.parse(json[:data][:createdAt])).to be_within(1).of(session[:created_at])
      expect(Time.parse(json[:data][:updatedAt])).to be_between(begin_time.floor, end_time)
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
      expect(json[:data].keys).to contain_exactly(:uuid, :user, :createdAt, :updatedAt)
      expect(json[:data][:uuid]).not_to eq uuid
      expect(json[:data][:user]).to be_nil
      expect(Time.parse(json[:data][:createdAt])).to be_between(begin_time.floor, end_time)
      expect(Time.parse(json[:data][:updatedAt])).to be_between(begin_time.floor, end_time)
    end
  end

  describe "session timeout" do
    let(:session) { timeover_session }

    it "is error" do
      begin_time = Time.now
      response = action.call(params)
      end_time = Time.now
      expect(response.status).to eq 200
      expect(response.headers["Content-Type"]).to eq "application/json; charset=utf-8"
      json = JSON.parse(response.body.first, symbolize_names: true)
      expect(json[:flash]).to eq({warn: "セッションがタイムアウトしました。"})
      expect(json[:data].keys).to contain_exactly(:uuid, :user, :createdAt, :updatedAt)
      expect(json[:data][:uuid]).to eq uuid
      expect(json[:data][:user]).to be_nil
      expect(Time.parse(json[:data][:createdAt])).to be_within(1).of(session[:created_at])
      expect(Time.parse(json[:data][:updatedAt])).to be_between(begin_time.floor, end_time)
    end
  end
end
