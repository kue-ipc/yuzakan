# frozen_string_literal: true

RSpec.describe API::Views::Parts::Group do
  subject { described_class.new(value:) }
  let(:value) { double("group") }

  it "works" do
    expect(subject).to be_kind_of(described_class)
  end
end
