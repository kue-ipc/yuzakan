# frozen_string_literal: true

RSpec.describe Yuzakan::Views::Parts::List do
  subject { described_class.new(value:) }

  let(:value) { double("list") }

  it "works" do
    expect(subject).to be_a(described_class)
  end
end
