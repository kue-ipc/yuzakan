# frozen_string_literal: true

RSpec.describe API::Views::Parts::User do
  subject { described_class.new(value:) }
  let(:value) { double("user") }

  it "works" do
    expect(subject).to be_kind_of(described_class)
  end
end
