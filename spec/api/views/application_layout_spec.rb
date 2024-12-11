# frozen_string_literal: true

require "spec_helper"

RSpec.describe Api::Views::ApplicationLayout, type: :view do
  let(:layout)   { described_class.new({format: :html}, "contents") }
  let(:rendered) { layout.render }

  it "contains application name" do
    expect(rendered).to include("Api")
  end
end
