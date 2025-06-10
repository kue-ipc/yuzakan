# frozen_string_literal: true

RSpec.describe API::Views::Parts::Auth do
  subject { described_class.new(value:) }

  let(:value) { double("auth") }

  it "works" do
    expect(subject).to be_a(described_class)
  end
end
