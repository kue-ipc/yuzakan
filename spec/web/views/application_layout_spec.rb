require 'spec_helper'

describe Web::Views::ApplicationLayout do
  let(:layout) do
    Web::Views::ApplicationLayout.new({format: :html}, 'contents')
  end
  let(:rendered) { layout.render }

  # it 'contains application name' do
  #   _(rendered).must_include('Web')
  # end
end
