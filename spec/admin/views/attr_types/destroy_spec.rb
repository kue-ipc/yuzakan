require_relative '../../../spec_helper'

describe Admin::Views::Attrs::Destroy do
  let(:exposures) { {format: :html} }
  let(:template)  do
    Hanami::View::Template.new('apps/admin/templates/attrs/destroy.html.slim')
  end
  let(:view)      { Admin::Views::Attrs::Destroy.new(template, **exposures) }
  let(:rendered)  { view.render }

  it 'exposes #format' do
    _(view.format).must_equal exposures.fetch(:format)
  end
end
