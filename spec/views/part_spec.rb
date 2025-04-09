# frozen_string_literal: true

RSpec.describe Yuzakan::Views::Part do
  subject { described_class.new(value:) }
  let(:value) { double("value") }

  it "works" do
    expect(subject).to be_kind_of(described_class)
  end
end
