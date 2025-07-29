# frozen_string_literal: true

RSpec.describe API::Views::Parts::Session do
  init_part_spec
  let_session

  let(:value) { session }

  it "to_h" do
    data = subject.to_h
    expect(data).to eq({
      uuid: value[:uuid],
      user: value[:user],
      trusted: value[:trusted],
      expires_at: Time.at(value[:expires_at]),
    })
  end

  it "to_json" do
    json = subject.to_json
    data = JSON.parse(json, symbolize_names: true)
    expect(data).to eq({
      uuid: value[:uuid],
      user: value[:user],
      trusted: value[:trusted],
      expiresAt: Time.at(value[:expires_at]).to_s,
    })
  end

  context "when first session" do
    let(:value) { first_session }

    it "to_h" do
      data = subject.to_h
      expect(data).to eq({
        uuid: nil,
        user: nil,
        trusted: nil,
        expires_at: nil,
      })
    end

    it "to_json" do
      json = subject.to_json
      data = JSON.parse(json, symbolize_names: true)
      expect(data).to eq({
        uuid: nil,
        user: nil,
        trusted: nil,
        expiresAt: nil,
      })
    end
  end
end
