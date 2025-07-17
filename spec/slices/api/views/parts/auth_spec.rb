# frozen_string_literal: true

RSpec.describe API::Views::Parts::Auth do
  init_part_spec

  let(:value) { {username: user.name } }

  it "to_h" do
    data = subject.to_h
    expect(data).to eq({
      username: value[:username],
    })
  end

  it "to_json" do
    json = subject.to_json
    data = JSON.parse(json, symbolize_names: true)
    expect(data).to eq({
      username: value[:username],
    })
  end
end
