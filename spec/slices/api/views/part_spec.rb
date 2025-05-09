# frozen_string_literal: true

RSpec.describe API::Views::Part do
  subject { described_class.new(value:) }

  let(:value) { double("value") }

  it "works" do
    expect(subject).to be_a(described_class)
  end
end
