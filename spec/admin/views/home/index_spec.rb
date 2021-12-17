require_relative '../../../spec_helper'

describe Admin::Views::Home::Index do
  let(:exposures) { {format: :html} }
  let(:template)  { Hanami::View::Template.new('apps/admin/templates/home/index.html.slim') }
  let(:view)      { Admin::Views::Home::Index.new(template, **exposures) }
  let(:rendered)  { view.render }

  it 'exposes #format' do
    _(view.format).must_equal exposures.fetch(:format)
  end
end
