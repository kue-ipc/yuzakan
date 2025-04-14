# frozen_string_literal: true

RSpec.describe API::Views::Parts::Session do
  subject { described_class.new(value:) }
  let(:value) { double("session") }

  it "works" do
    expect(subject).to be_kind_of(described_class)
  end
end
