require "spec_helper"

describe Legacy::Views::ApplicationLayout do
  let(:layout)   { Legacy::Views::ApplicationLayout.new({ format: :html }, "contents") }
  let(:rendered) { layout.render }

  it 'contains application name' do
    rendered.must_include('Legacy')
  end
end
