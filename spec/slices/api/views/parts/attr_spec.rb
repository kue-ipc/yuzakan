# frozen_string_literal: true

RSpec.describe API::Views::Parts::Attr do
  subject { described_class.new(value:) }
  let(:value) { double("attr") }

  it "works" do
    expect(subject).to be_kind_of(described_class)
  end
end
