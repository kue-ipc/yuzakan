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
    expect(json[:data].except(:expiresAt)).to eq({
      uuid: uuid,
      user: user.name,
      trusted: true,
    })
    expect(Time.parse(json[:data][:expiresAt])).to be_between(begin_time.floor + 3600, end_time + 3600)
  end

  context "when logout" do
    include_context "when logout"

    it "is successful" do
      begin_time = Time.now
      response = action.call(params)
      end_time = Time.now
      expect(response).to be_successful
      expect(response.status).to eq 200
      expect(response.headers["Content-Type"]).to eq "application/json; charset=utf-8"
      json = JSON.parse(response.body.first, symbolize_names: true)
      expect(json[:data].except(:expiresAt)).to eq({
        uuid: uuid,
        user: nil,
        trusted: false,
      })
      expect(Time.parse(json[:data][:expiresAt])).to be_between(begin_time.floor + 3600, end_time + 3600)
    end
  end

  context "when first" do
    include_context "when first"

    it "is successful" do
      begin_time = Time.now
      response = action.call(params)
      end_time = Time.now
      expect(response).to be_successful
      expect(response.status).to eq 200
      expect(response.headers["Content-Type"]).to eq "application/json; charset=utf-8"
      json = JSON.parse(response.body.first, symbolize_names: true)
      expect(json[:data].except(:uuid, :expiresAt)).to eq({
        user: nil,
        trusted: false,
      })
      expect(json[:data][:uuid]).to be_a_uuid(version: 4)
      expect(json[:data][:uuid]).not_to eq uuid
      expect(Time.parse(json[:data][:expiresAt])).to be_between(begin_time.floor + 3600, end_time + 3600)
    end
  end

  describe "when timeover" do
    include_context "when timeover"

    it "is error" do
      begin_time = Time.now
      response = action.call(params)
      end_time = Time.now
      expect(response.status).to eq 200
      expect(response.headers["Content-Type"]).to eq "application/json; charset=utf-8"
      json = JSON.parse(response.body.first, symbolize_names: true)
      expect(json[:flash]).to eq({warn: "セッションがタイムアウトしました。"})
      json = JSON.parse(response.body.first, symbolize_names: true)
      expect(json[:data].except(:expiresAt)).to eq({
        uuid: uuid,
        user: nil,
        trusted: false,
      })
      expect(Time.parse(json[:data][:expiresAt])).to be_between(begin_time.floor + 3600, end_time + 3600)
    end
  end
end
