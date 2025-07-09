# frozen_string_literal: true

RSpec.describe API::Views::Parts::Auth do
  subject { described_class.new(value:) }

  let(:value) { {username: fake(:internet, :username)} }

  it "to_h" do
    expect(subject.to_h).to eq(value)
  end

  it "to_json" do
    json = JSON.parse(subject.to_json, symbolize_names: true)
    expect(json).to eq(value)
  end
end
