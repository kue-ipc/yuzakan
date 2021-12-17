require_relative '../../../spec_helper'

describe Admin::Views::Attrs::Create do
  let(:exposures) { {format: :html} }
  let(:template)  { Hanami::View::Template.new('apps/admin/templates/attrs/create.html.slim') }
  let(:view)      { Admin::Views::Attrs::Create.new(template, **exposures) }
  let(:rendered)  { view.render }

  it 'exposes #format' do
    _(view.format).must_equal exposures.fetch(:format)
  end
end
