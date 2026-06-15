# frozen_string_literal: true

RSpec.describe API::Views::StructPart do
  init_part_spec

  let(:value) { {id: 0, created_at: Time.now, updated_at: Time.now, name: "hoge"} }

  it "to_h" do
    data = subject.to_h
    expect(data).to eq({name: value[:name]})
  end

  it "to_json" do
    json = subject.to_json
    data = JSON.parse(json, symbolize_names: true)
    expect(data).to eq({name: value[:name]})
  end
end
