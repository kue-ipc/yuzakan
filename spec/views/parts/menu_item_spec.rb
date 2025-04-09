# frozen_string_literal: true

RSpec.describe Yuzakan::Views::Parts::MenuItem do
  subject { described_class.new(value:) }
  let(:value) { double("menu_item") }

  it "works" do
    expect(subject).to be_kind_of(described_class)
  end
end
