require_relative '../../../spec_helper'

describe Web::Views::Uninitialized::Index do
  let(:exposures) { {format: :html} }
  let(:template)  do
    Hanami::View::Template.new('apps/web/templates/uninitialized/index.html.slim')
  end
  let(:view)      { Web::Views::Uninitialized::Index.new(template, **exposures) }
  let(:rendered)  { view.render }

  it 'exposes #format' do
    _(view.format).must_equal exposures.fetch(:format)
  end
end
