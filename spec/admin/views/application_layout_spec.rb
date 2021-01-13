require 'spec_helper'

describe Admin::Views::ApplicationLayout do
  let(:layout) do
    Admin::Views::ApplicationLayout.new({format: :html}, 'contents')
  end
  let(:rendered) { layout.render }

  # it 'contains application name' do
  #   _(rendered).must_include('Admin')
  # end
end
