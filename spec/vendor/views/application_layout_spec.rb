require "spec_helper"

RSpec.describe Vendor::Views::ApplicationLayout, type: :view do
  let(:layout)   { Vendor::Views::ApplicationLayout.new({ format: :html }, "contents") }
  let(:rendered) { layout.render }

  it 'contains application name' do
    expect(rendered).to include('Vendor')
  end
end
